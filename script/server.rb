self_file =
  if File.symlink?(__FILE__)
    require 'pathname'
    Pathname.new(__FILE__).realpath
  else
    __FILE__
  end
$:.unshift(File.dirname(self_file) + "/../lib")

require 'bundler/setup'
require 'shikoku'
require 'sinatra'

get '/:token' do
  collection = Shikoku::Database.collection('application/ruby')
  token = params[:token]
  total = collection.find.count
  found = collection.find({
      'value' => token
    }).count

  p [token, found, total]
  (100.0 * found / total).to_s
end
