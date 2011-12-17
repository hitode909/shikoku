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

  end

  get '/' do
    erb :index
  end

  post '/' do
    body = params[:body]
    halt 400 unless body
    mime_type = params[:mime_type] || 'application/ruby'
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
end
