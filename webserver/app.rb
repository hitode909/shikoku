# -*- coding: utf-8 -*-
require 'json'
require 'set'

class ShikokuApp < Sinatra::Base

  helpers do

    def get_token_count(token)
      Shikoku::Database.collection('application/ruby/count_summary').find_one({ 'value' => token})['count']
    rescue
      0
    end

    def token_collection
      Shikoku::Database.collection('application/ruby')
    end

    def get_token_total
      Shikoku::Database.collection('application/ruby').count
    end

    def get_file_count(token)
      Shikoku::Database.collection('application/ruby/file_summary').find_one({ 'value' => token})['count']
    rescue
      0
    end

    def get_file_total
      Shikoku::Database.collection('application/ruby/files').count
    end

    # simple...
    def get_near_tokens(token)
      res = []
      (1...token.length).to_a.reverse.each{|to|
        rule = Regexp.new('^' + Regexp.quote(token[0..to]))
        p [rule, res.length]
        list = Shikoku::Database.collection('application/ruby/file_summary').find({ 'value' => rule}, { :limit => 50}).to_a.sort_by{ |_| _['value'].length }
        res.concat(list).uniq!
        p [rule, res.length]
        break if res.length >= 10
      }
      res[0..10]
    end

    def get_file_set(token)
      entries = token_collection.find({'value' => token})
      entries.inject(Set.new){ |set, entry|
        set << [entry['url'], entry['path']].join('-')
      }
    end

    def get_file_set_hash_from_tokens(tokens)
      res = { }
      from = Time.now
      entries = token_collection.find({
          "$or" => tokens.select{ |s| s =~ /\S/ }.map{ |token|
            { 'value' => token}
          }
        })
      entries.each{ |entry|
        value = entry['value']
        file_key = [entry['url'], entry['path']].join('-')
        res[value] ||= Set.new
        res[value] << file_key
      }
      res
    end

    def get_co_rate(set_a, set_b)
      return 0 if set_a.length == 0 || set_b.length == 0
      (set_a & set_b).length.to_f / (set_a + set_b).length.to_f
    end
end

  get '/' do
    @tokens_count = Shikoku::Database.collection('application/ruby').count
    @files_count  = Shikoku::Database.collection('application/ruby/files').count

    erb :index
  end

  get '/suggest' do
    token = params[:token]
    halt 400 unless token
    content_type :json
    total = get_file_total
    res = get_near_tokens(token).map{ |entry|
      {
        :value => entry['value'],
        :count => entry['count'],
        :rate => entry['count'].to_f / total
      }
    }
    JSON.unparse(res)
  end

  post '/' do
    body = params[:body]
    halt 400 unless body
    mime_type = params[:mime_type] || 'application/ruby'
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'x-requested-with'
    collection = Shikoku::Database.collection(mime_type)
    tokenizer = Shikoku::Tokenizer.new_from_content_and_mime_type(body, mime_type)
    tokens = tokenizer.tokenize
    total = get_file_total
    content_type :json

    count_cache ||= { }
    res = { :total => total, :tokens => []}
    tokens.each{ |token|
      unless count_cache.has_key? token
        if token =~ /\S/
          count_cache[token] = get_file_count(token)
        else
          count_cache[token] = 0
        end
      end
      count = count_cache[token]
      p [token, count]
      res[:tokens] << {
        :value => token,
        :count => count,
        :rate => count.to_f / total,
      }
    }
    JSON.unparse(res)
  end

  post '/focus' do
    body  = params[:body]
    focus = params[:focus]
    halt 400 unless body
    halt 400 unless focus
    mime_type = params[:mime_type] || 'application/ruby'
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'x-requested-with'
    collection = Shikoku::Database.collection(mime_type)
    tokenizer = Shikoku::Tokenizer.new_from_content_and_mime_type(body, mime_type)
    tokens = tokenizer.tokenize
    halt 400 unless tokens.find{ |s| s == focus}
    content_type :json

    set_cache = get_file_set_hash_from_tokens(tokens)
    res = { :focus => focus, :tokens => []}
    focus_set = set_cache[focus]
    tokens.each{ |token|
      tokens_set = set_cache[token]
      rate = get_co_rate(focus_set, tokens_set)
      res[:tokens] << {
        :value => token,
        :count => (focus_set & tokens_set).length,
        :rate => rate,
      }
    }
    JSON.unparse(res)
  end

  options '/' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'x-requested-with'
    'options'
  end
end
