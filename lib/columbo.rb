require 'columbo/version'
require 'columbo/api_client'
require 'columbo/inspector'
require 'columbo/log_writer'
require 'columbo/compressor'

module Columbo
  def self.logger
    @logger
  end

  def self.logger=(log = STDOUT)
    @logger = Columbo::LogWriter.new log
  end
end