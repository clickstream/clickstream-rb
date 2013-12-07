require 'sinatra'
require 'clickstream/capture'
require 'lorem'

use Clickstream::Capture, {
  capture: true,
  api_key: "23dd4ff5-3404-4647-abf5-d63f9e776ffe",
  logger: 'log/clickstream.log',
  bench: true
}

get '/' do
  erb :index
end

get '/foo' do
  erb :foo
end