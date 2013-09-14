require 'sinatra'
require 'columbo/capture'
require 'lorem'

use Columbo::Capture, {
  capture: true,
  #api_key: "23dd4ff5-3404-4647-abf5-d63f9e776ffe",
  api_key: "1234",
  logger: 'log/columbo.log',
  bench: true
}

get '/' do
  erb :index
end

get '/foo' do
  erb :foo
end