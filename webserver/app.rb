# -*- coding: utf-8 -*-
require 'json'
require 'set'

class ShikokuApp < Sinatra::Base

  helpers do

    def stopwatch(title, &block)
      from = Time.now
      res = yield block
      warn "#{title}\t#{Time.now - from}"
      res
    end

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

    # サマリーから引く
    def get_file_set_hash_from_tokens(tokens)
      file_counts = get_file_counts(tokens)

      cond = {
        "$or" => tokens.uniq.select{ |s| s =~ /\S/ && file_counts[s]}.map{ |token|
          { 'value' => token}
        }
      }
      res = {}
      collection = Shikoku::Database.collection('application/ruby/file_token')

      stopwatch("retrieve"){
        cursor = collection.find(cond)
        cursor.each{ |entry|
          res[entry['value']] ||= Set.new
          res[entry['value']] << [entry['url'], entry['path']].join('-')
        }
      }

      res
    end

    # サマリー，ちょろちょろ引く
    def get_file_set_hash_from_tokens_liner(tokens)
      tokens.select{ |s| s =~ /\S/ }.uniq.each{ |token|
        keys = collection.find({ :value => token}).to_a.map{ |entry|
          [entry['url'], entry['path']].join('-')
        }
        res[token] = Set.new(keys)
      }
      res
    end

    # 動くけど1分くらいかかる
    def get_file_set_hash_from_tokens_group(tokens)
      cond = {
        "$or" => tokens.select{ |s| s =~ /\S/ }.uniq.map{ |token|
          { 'value' => token}
        }
      }
      from = Time.now
      list = token_collection.group(
        :cond => cond,
        :key => [:value],
        :initial => { :summary => {}, :keys => [] },
        :reduce => "function(doc, out) { out.summary[doc.url + '/' + doc.path] = true; }",
        :finalize => "function(out) { for (var key in out.summary) { out.keys.push(key); }; delete out.summary; return out; }"
        )

      # [ { String value, [String] keys } ]

      res = { }
      list.each{ |item|
        res[item['value']] = Set.new(item['keys'])
      }

      # { String value: Set(String) keys }

      res
    end

    def get_file_set_hash_from_tokens_old(tokens)
      res = { }
      from = Time.now
      query = [{
          "$or" => tokens.select{ |s| s =~ /\S/ }.uniq.map{ |token|
            { 'value' => token}
          }
        }, {
          :fields => [:url, :path, :value]
      }]
      entries = token_collection.find(*query)
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

    def get_file_counts(tokens)
      uniq_tokens = tokens.select{ |s| s =~ /\S/ }.uniq
      return { } if uniq_tokens.empty?
      cond = {
        "$or" => uniq_tokens.select{ |s| s =~ /\S/ }.uniq.map{ |token|
          { 'value' => token}
        }
      }
      collection = Shikoku::Database.collection('application/ruby/file_summary')
      res = { }
      collection.find(cond).each{ |entry|
        res[entry['value']] = entry['count']
      }
      res
    end

    def get_file_classes(tokens)
      uniq_tokens = tokens.select{ |s| s =~ /\S/ }.uniq
      return { } if uniq_tokens.empty?
      cond = {
        "$or" => uniq_tokens.map{ |token|
          { 'value' => token}
        }
      }
      collection = Shikoku::Database.collection('application/ruby/count_summary')
      res = { }
      collection.find(cond).each{ |entry|
        max = entry['token_class'].each_pair.map{ |k, v|
          [k, v]
        }.sort_by{ |pair| pair[1]}.last[0]
        res[entry['value']] = max
      }
      res
    end

    def save_token_classes(tokens)
      collection = Shikoku::Database.collection('application/ruby/count_summary')
      tokens.each{ |v|
        collection.update({ :value => v.content }, { :$inc => { :count => 1, :"token_class.#{v.token_class}" => 1}}, {:upsert => true})
      }
    end

    def get_class_for_may_token(token)
      # Da ta base  とかにしてしまう これではだめ
      variations = (0..token.length).map{ |i| token[0..i] }

      cond = {
        "$or" => variations.map{ |v|
          { 'value' => v}
        }
      }
      p cond

      collection = Shikoku::Database.collection('application/ruby/count_summary')
      table = { }
      collection.find(cond).each{ |entry|
        table[entry['value']] = entry
      }
      found_key = variations.reverse.find{ |v|
        table[v]
      }
      found = table[found_key]

      return {
        :value => token,
        :token_class => 'nil',
      } unless found

      if found
        token_class = found['token_class'].each_pair.map{ |k, v|
          [k, v]
        }.sort_by{ |pair| pair[1]}.last[0]
        return {
          :value => found['value'],
          :token_class => token_class
        }
      end
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

    content_type :json

    if tokenizer.is_valid
      tokens = tokenizer.tokenize
      save_token_classes(tokens)
      res = { :tokens => [], :is_valid => tokenizer.is_valid }
      tokens.each{ |token|
        res[:tokens] << {
          :value => token.content,
          :token_class => token.token_class,
        }
      }
      return JSON.unparse(res)
    end

    # -------------- コンパイル通らないときは適当に切って過去のを使う

    res = { :tokens => [], :is_valid => false }

    tokens = body.split(/(\s+)/).map{ |s| s.split(/\b/) }.flatten

    counts = get_file_classes(tokens)

    res = { :tokens => [] }
    tokens.each{ |token|
      token_class = counts[token] || '?'
      res[:tokens] << {
        :value => token,
        :token_class => token_class,
      }
    }

    return JSON.unparse(res)
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

    res_cache = { }
    set_cache = get_file_set_hash_from_tokens(tokens)
    res = { :focus => focus, :tokens => []}
    focus_set = set_cache[focus]
    tokens.each{ |token|
      tokens_set = set_cache[token] || Set.new
      rate = get_co_rate(focus_set, tokens_set)
      res_cache[token] ||= {
        :value => token,
        :count => (focus_set & tokens_set).length,
        :rate => rate,
      }
      res[:tokens] << res_cache[token]
    }
    JSON.unparse(res)
  end

  options '/' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'x-requested-with'
    'options'
  end
end
