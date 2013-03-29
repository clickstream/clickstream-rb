require 'columbo/version'
require 'columbo/db_client'
require 'columbo/inspector'
require 'columbo/log_writer'

module Columbo
  MONGO_COLLECTION = "hits".freeze

  def self.logger
    @logger
  end

  def self.logger=(log = STDOUT)
    @logger = Columbo::LogWriter.new log
  end
end