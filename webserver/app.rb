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
end


  get '/' do
    erb :index
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
        count_cache[token] = get_file_count(token)
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
