require 'clickstream/version'
require 'clickstream/api_client'
require 'clickstream/capture'
require 'clickstream/inspector'
require 'clickstream/log_writer'
require 'clickstream/compressor'

module Clickstream
  def self.logger
    @logger
  end

  def self.logger=(log = STDOUT)
    @logger = Clickstream::LogWriter.new log
  end
end