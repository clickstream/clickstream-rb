require 'rack/request'
require 'rack/response'
require 'socket'

module Clickstream
  class Inspector

    def initialize(api_key, api_uri, crawlers, capture_crawlers, filter_params)
      @client = Clickstream::APIClient.new(api_key, api_uri)
      @crawlers, @capture_crawlers, @filter_params = crawlers, capture_crawlers, filter_params
      @hostname = Socket.gethostname
      @rg = Regexp.new(crawlers, Regexp::IGNORECASE)
    end

    def investigate(env, status, headers, body, start, stop, cookie, pid)
      # Normalise request from env
      request = Rack::Request.new(env)
      # Don't capture bots traffic by default
      return unless @capture_crawlers || !request.user_agent.match(@rg)
      html = ''
      # in case of gzipping has been done by the app
      body.each { |part| html += Clickstream::Compressor.unzip(part, headers['Content-Encoding']) }
      request_headers = {}
      request.env.each { |key, value| request_headers[key.sub(/^HTTP_/, '').gsub(/_/, '-').downcase] = value if key.start_with? 'HTTP_'}
      params = request.params.clone || {}
      @filter_params.each {|param| params[param.to_s] = '[FILTERED]' if params[param.to_s]}
      session_opts = request.session_options.clone || {}
      session_opts.delete :secret
      data = {
          sid: cookie,
          pid: pid,
          hostname: @hostname,
          filter_params: @filter_params,
          request: {
              params: params,
              ip: request.ip,
              user_agent: request.user_agent,
              referer: request.referer,
              method: request.request_method,
              path: request.path, # script_name + path_info
              fullpath: request.fullpath, # "#{path}?#{query_string}"
              script_name: request.script_name,
              path_info: request.path_info,
              uri: request.env['REQUEST_URI'],
              querystring: request.query_string,
              scheme: request.scheme,
              host: request.host,
              port: request.port,
              url: request.url, # base_url + fullpath
              base_url: request.base_url, # scheme + host [+ port]
              content_type: request.content_type,
              content_charset: request.content_charset,
              media_type: request.media_type,
              media_type_params: request.media_type_params,
              protocol: request.env['HTTP_VERSION'],
              session: request.session,
              session_options: session_opts,
              cookies: request.cookies,
              path_parameters: request.env['action_dispatch.request.path_parameters'],
              headers: request_headers,
              xhr: request.xhr?
          },
          response: {
              status: status,
              headers: headers,
              size: html.length,
              body: html,
              start: start,
              stop: stop,
              time: (stop-start)*1000
          }
      }
      # Send data to API
      @client.post_data data
    end

  end
end