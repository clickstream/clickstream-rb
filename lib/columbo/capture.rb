require 'columbo'
require 'rack/utils'
require 'rack/logger'

module Columbo
  class Capture
    include Rack::Utils

    FORMAT = %{[Columbo #{Columbo::VERSION}] [%s] %s - %s "%s%s %s\n}

    def initialize(app, opts={})
      @app = app
      @capture    = opts[:capture]
      @bench      = opts[:capture] && opts[:bench]
      @mongo_uri  = opts[:mongo_uri]

      Columbo.logger = opts[:logger] if opts[:logger]

      raise ArgumentError, 'mongo URI missing.' if @mongo_uri.nil?

      @inspector = Columbo::Inspector.new @mongo_uri
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      start_processing = Time.now
      status, headers, response = @app.call(env)
      stop_processing = Time.now

      start = Time.now if @bench

      headers = HeaderHash.new(headers) # Is it required?

      if !STATUS_WITH_NO_ENTITY_BODY.include?(status) &&
          !headers['transfer-encoding'] &&
          headers['content-type'] &&
          headers['content-type'].include?("text/html")

        Thread.abort_on_exception = true

        Thread.new do
          begin
            @inspector.investigate env, status, headers, response, start_processing, stop_processing
          rescue Exception => e
            log_error env, e
          end
        end if @capture

      end

      if @bench
        stop = Time.now
        duration = ((stop-start).seconds * 1000).round(3)
        log(env, "Time: #{duration}ms")
        headers['Columbo'] = "version #{Columbo::VERSION}, time #{duration}ms"
      end

      [status, headers, response]
    end

    private

    def log(env, message)
      now = Time.now

      logger = Columbo.logger || env['rack.errors']

      logger.write FORMAT % [
          now.strftime('%d-%b-%Y %H:%M:%S'),
          message,
          env['REQUEST_METHOD'],
          env['PATH_INFO'],
          env['QUERY_STRING'].empty? ? '' : '?' + env['QUERY_STRING'],
          env['HTTP_VERSION']
      ]
    end

    def log_error(env, exception)
      begin
        logger = Columbo.logger || env['rack.errors']
        log env, "Error: " + exception.message
        logger.write "#{exception.backtrace.join("\n")}\n"
      end
    end

  end
end