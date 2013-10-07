require 'columbo'
require 'rack/utils'
require 'rack/logger'
require 'securerandom'

module Columbo
  class Capture
    include Rack::Utils

    attr_reader :client

    FORMAT = %{[Columbo #{Columbo::VERSION}] [%s] %s - %s "%s%s %s\n}

    def initialize(app, opts={})
      @app = app
      # Options
      @capture          = !!opts[:capture]
      @bench            = opts[:capture] && opts[:bench]
      capture_crawlers  = opts[:capture_crawlers]
      crawlers          = opts[:crawlers] || "(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg|bot|crawler|spider|robot|crawling|facebook|w3c|coccoc|Daumoa|panopta)"
      api_key           = opts[:api_key]
      api_uri           = opts[:api_uri]
      filter_params     = opts[:filter_parameters] || []

      @cookie_name = 'columbo'
      filter_params = Rails.configuration.filter_parameters || [] if defined? Rails

      Columbo.logger = opts[:logger] if opts[:logger]

      raise ArgumentError, 'API key missing.' if api_key.nil?

      @inspector = Columbo::Inspector.new api_key, api_uri, crawlers, capture_crawlers, filter_params
      @cookie_regex = Regexp.new "#{@cookie_name}="

      @client = {}
      Columbo::APIClient.new(api_key, api_uri).handshake { |k, v| @client[k] = v}
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

      if !STATUS_WITH_NO_ENTITY_BODY.include?(status) && !headers['transfer-encoding'] && headers['content-type'] && (
        headers['content-type'].include?('text/html') || headers['content-type'].include?('application/json') ||
            headers['content-type'].include?('application/xml') || headers['content-type'].include?('text/javascript')
      )

        cookie = session_cookie(env, headers)
        pid = SecureRandom.uuid

        Thread.abort_on_exception = true
        Thread.new do
          begin
            result = @inspector.investigate env, status, headers, response.clone, start_processing, stop_processing, cookie, pid
            log env, result
          rescue Exception => e
            log_error env, e
          end
        end if @capture

        response = insert_js(response, headers, cookie, pid) if headers['content-type'].include?('text/html') #&& headers['content-length'].to_i > 0
      end

      if @bench
        stop = Time.now
        duration = ((stop-start) * 1000).round(3)
        headers['Columbo'] = "version #{Columbo::VERSION}, time #{duration}ms"

        Thread.abort_on_exception = false
        Thread.new { log(env, "Time: #{duration}ms") }
      end

      [status, headers, response]
    end

    private

    def session_cookie(env, headers)
      cookie = extract_cookie(env['HTTP_COOKIE'])
      set_cookie(headers, cookie)
    end

    def extract_cookie(string)
      return unless string
      match = string.match(/columbo=([^;]*)/)
      match[1] if match && match.length > 1
    end

    def set_cookie(headers, cookie)
      expires = Time.now+60*60
      cookie = cookie.nil? ? {value: SecureRandom.uuid} : {value: cookie}
      cookie[:expires] = expires
      Rack::Utils.set_cookie_header!(headers, @cookie_name, cookie)
      cookie[:value]
    end

    def insert_js(body, headers, sid, pid)
      html = ''
      body.each { |part| html += part }
      body.close if body.respond_to?(:close)
      if html.size > 0
        script = "<script>(function(){var uri='#{client['ws']}', cid='#{client['clientId']}', sid='#{sid}', pid='#{pid}';#{client['js']}})();</script>"
        html += "\n" + script
      end
      headers['content-length'] = html.size.to_s
      [html]
    end

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