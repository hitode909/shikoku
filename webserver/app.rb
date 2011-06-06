# -*- coding: utf-8 -*-
require 'json'
class ShikokuApp < Sinatra::Base

  helpers do

    def get_count(token)
      summary = Shikoku::Database.collection('application/ruby/summary').find_one({ 'value' => token})
      summary ? summary['count'] : 0
    end

    def get_total
      @total || Shikoku::Database.collection('application/ruby').count
    end
  end


  get '/' do
    erb :index
  end

  get '/:token' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'x-requested-with'
    token = params[:token]
    found = get_count(token)
    total = get_total

    p [token, found, total]
    (100.0 * found / total).to_s
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
    total = get_total
    content_type :json

   cache ||= { }
    res = []
    tokens.each{ |token|
      unless cache.has_key? token
        cache[token] = 100.0 * get_count(token) / total
      end
      rate = cache[token]
      p [token, rate]
      res << [token, rate]
    }
    JSON.unparse(res)
  end

  options '/' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'x-requested-with'
    'options'
  end
end
