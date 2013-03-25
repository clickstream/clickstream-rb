require 'columbo/version'
require 'columbo/db_client'
require 'columbo/inspector'

module Columbo
  MONGO_URI = "mongodb://columbo:inspector@linus.mongohq.com:10025/columbo_test".freeze
  MONGO_DB = "columbo_test".freeze
  MONGO_COLLECTION = "tests".freeze
end