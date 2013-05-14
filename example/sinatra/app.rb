require 'sinatra'
require 'columbo/capture'

use Columbo::Capture, {
  capture: true,
  api_key: "1234",
  logger: 'log/columbo.log',
  bench: true
}

get '/' do
  erb :index
end