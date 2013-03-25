require 'columbo'
require 'rack/utils'
require 'rack/logger'

module Columbo
  class Capture
    include Rack::Utils

    FORMAT = %{[Columbo #{Columbo::VERSION}] %s - [%s] %s "%s%s %s"\n}

    def initialize(app, opts={})
      @app = app
      @capture = opts[:capture] || false
      @bench = (opts[:capture] && opts[:bench]) || false
      @logger = opts[:logger]
      @inspector = Columbo::Inspector.new
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

        Thread.new { @inspector.investigate env, status, headers, response, start_processing, stop_processing if @capture }

      end

      if @bench
        stop = Time.now
        log(env, (stop-start).seconds)
        headers['Columbo'] = "version #{Columbo::VERSION}, time #{(stop-start).seconds}s"
      end

      [status, headers, response]
    end

    private

    def log(env, time)
      now = Time.now
      logger = @logger || env['rack.errors']

      logger.write FORMAT % [
          "Time: #{time}s",
          now.strftime("%d-%b-%Y %H:%M:%S"),
          env["REQUEST_METHOD"],
          env["PATH_INFO"],
          env["QUERY_STRING"].empty? ? "" : "?"+env["QUERY_STRING"],
          env["HTTP_VERSION"]
      ]
    end

  end
end