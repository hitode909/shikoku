# -*- coding: utf-8 -*-

class ShikokuApp < Sinatra::Base


  get '/' do
    erb :index
  end

  get '/:token' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'x-requested-with'
    collection = Shikoku::Database.collection('application/ruby')
    token = params[:token]
    total = collection.find.count
    found = collection.find({
        'value' => token
      }).count

    p [token, found, total]
    (100.0 * found / total).to_s
  end

  post '/' do
    body = params[:body]
    mime_type = params[:mime_type] || 'application/ruby'
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'x-requested-with'
    collection = Shikoku::Database.collection(mime_type)
    tokenizer = Shikoku::Tokenizer.new_from_content_and_mime_type(body, mime_type)
    tokenizer.tokenize.join("\n")
  end

  options '/' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'x-requested-with'
    'options'
  end
end


  __END__
  @@index
