# -*- coding: utf-8 -*-
require 'json'
class ShikokuApp < Sinatra::Base

  helpers do

    def get_token_count(token)
      Shikoku::Database.collection('application/ruby/count_summary').find_one({ 'value' => token})['count']
    rescue
      0
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
end

  get '/' do
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

  options '/' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'x-requested-with'
    'options'
  end
end
