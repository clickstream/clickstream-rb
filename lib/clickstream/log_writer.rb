require 'logger'

module Clickstream

  class LogWriter < Logger
    def initialize(log = STDOUT)
      super(log)
      self.level = Logger::INFO
      self.formatter = Simple.new
      self
    end

    def write(message)
      add Logger::INFO, message
    end

    class Simple < Logger::Formatter
      # Provide a call() method that returns the formatted message.
      def call(severity, time, program_name, message)
        "#{message}"
      end
    end

  end
end