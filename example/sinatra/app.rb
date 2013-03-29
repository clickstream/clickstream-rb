require 'sinatra'
require 'columbo/capture'

use Columbo::Capture, {
  capture: true,
  mongo_uri: 'mongodb://columbo:inspector@linus.mongohq.com:10025/columbo_test'
}

get '/' do
  erb :index
end