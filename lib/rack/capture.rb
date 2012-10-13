require 'colombo'
require 'rack/utils'
require 'rack/logger'

module Rack
  class Capture
    include Rack::Utils

    FORMAT = %{[Colombo #{Colombo::VERSION}] %s - [%s] %s "%s%s %s"\n}

    def initialize(app, opts={})
      @app = app
      @bench = opts[:bench] || true
      @logger = opts[:logger]
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      status, headers, response = @app.call(env)
      start = Time.now if @bench
      # TODO: create GUID, capture status, header, set cookie

      headers = HeaderHash.new(headers) # Is it required?

      if !STATUS_WITH_NO_ENTITY_BODY.include?(status) &&
          !headers['transfer-encoding'] &&
          headers['content-type'] &&
          headers['content-type'].include?("text/html")

        body = ""
        response.each { |part| body += part }

        # TODO: capture body in DB
      end

      stop = Time.now and log(env, (stop-start).seconds) if @bench
      headers['Colombo'] = "version #{Colombo::VERSION}, time #{(stop-start).seconds}s" if @bench

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