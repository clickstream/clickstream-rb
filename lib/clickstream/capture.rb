require 'clickstream'
require 'rack/utils'
require 'rack/logger'
require 'securerandom'

module Clickstream
  class Capture
    include Rack::Utils

    attr_reader :client, :filter_params, :filter_uri

    FORMAT = %{[Clickstream #{Clickstream::VERSION}] [%s] %s - %s "%s%s %s\n}
    COOKIE_NAME = 'clickstream.io'.freeze
    COOKIE_REGEX = Regexp.new("#{COOKIE_NAME}=([^;]*)").freeze

    def initialize(app, opts={})
      @app = app
      # Options
      @capture          = !!opts[:capture]
      @bench            = opts[:capture] && opts[:bench]
      capture_crawlers  = opts[:capture_crawlers]
      crawlers          = opts[:crawlers] || "(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg|bot|crawler|spider|robot|crawling|facebook|w3c|coccoc|Daumoa|panopta)"
      api_key           = opts[:api_key]
      api_uri           = opts[:api_uri]
      @filter_params    = opts[:filter_params] || []
      @filter_uri       = opts[:filter_uri] || []

      filter_params.concat(Rails.configuration.filter_parameters || []) if defined?(Rails)

      Clickstream.logger = opts[:logger] if opts[:logger]

      raise ArgumentError, 'API key missing.' if api_key.nil?

      @inspector = Clickstream::Inspector.new api_key, api_uri, crawlers, capture_crawlers, filter_params

      @client = {}
      Clickstream::APIClient.new(api_key, api_uri).handshake { |k, v| @client[k] = v}
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      start_processing = Time.now
      status, headers, response = @app.call(env)
      stop_processing = Time.now

      start = Time.now if @bench

      headers = HeaderHash.new(headers)

      if @capture && !STATUS_WITH_NO_ENTITY_BODY.include?(status) && !headers['transfer-encoding'] && headers['content-type'] && (
        headers['content-type'].include?('text/html') || headers['content-type'].include?('application/json') ||
            headers['content-type'].include?('application/xml') || headers['content-type'].include?('text/javascript') ||
            headers['content-type'].include?('text/plain')
      ) && !filtered_uri?(env['REQUEST_URI'])

        cookie = session_cookie(env, headers)
        pid = SecureRandom.uuid
        body = response.clone

        Thread.abort_on_exception = false
        Thread.new do
          begin
            result = @inspector.investigate env, status, headers, body, start_processing, stop_processing, cookie, pid
            log env, result
          rescue Exception => e
            log_error env, e
          end
        end

        response = insert_js(response, headers, cookie, pid) if headers['content-type'].include?('text/html') #&& headers['content-length'].to_i > 0
      end

      if @bench
        stop = Time.now
        duration = ((stop-start) * 1000).round(3)
        headers['Clickstream'] = "version #{Clickstream::VERSION}, time #{duration}ms"
        Thread.new { log(env, "Time: #{duration}ms") }
      end

      [status, headers, response]
    end

    private

    def filtered_uri?(uri)
      filter_uri.select {|filter| uri.match filter}.size > 0
    end

    def session_cookie(env, headers)
      cookie = extract_cookie(env['HTTP_COOKIE'])
      set_cookie(headers, cookie)
    end

    def extract_cookie(string)
      return unless string
      match = string.match(COOKIE_REGEX)
      match[1] if match && match.length > 1
    end

    def set_cookie(headers, cookie)
      expires = Time.now+60*60
      cookie = cookie.nil? ? {value: SecureRandom.uuid} : {value: cookie, path: '/'}
      cookie[:expires] = expires
      Rack::Utils.set_cookie_header!(headers, COOKIE_NAME, cookie)
      cookie[:value]
    end

    def insert_js(body, headers, sid, pid)
      html = ''
      body.each { |part| html += part }
      body.close if body.respond_to?(:close)
      str_filter_params = filter_params.map { |filter| filter.to_s }
      if html.size > 0
        script = "<script>(function(){var uri='#{client['ws']}', cid='#{client['clientId']}', sid='#{sid}', pid='#{pid}', paramsFilter = #{str_filter_params}; #{client['js']}})();</script>"
        html += "\n" + script
      end
      headers['content-length'] = html.size.to_s
      [html]
    end

    def log(env, message)
      now = Time.now

      logger = Clickstream.logger || env['rack.errors']

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
        logger = Clickstream.logger || env['rack.errors']
        log env, "Error: " + exception.message
        logger.write "#{exception.backtrace.join("\n")}\n"
      end
    end

  end
end