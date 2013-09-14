require 'rack/request'
require 'rack/response'
require 'nokogiri'
require 'html_mini'

module Columbo
  class Inspector

    def initialize(api_key, api_uri)
      @client = Columbo::APIClient.new(api_key, api_uri)
    end

    def investigate(env, status, headers, body, start, stop, crawlers, capture_crawlers, cookie)
      # Normalise request from env
      request = Rack::Request.new(env)
      # Don't capture bots traffic by default
      rg = Regexp.new(crawlers, Regexp::IGNORECASE)
      return if request.user_agent.match(rg) && !capture_crawlers
      html = ''
      # TODO: move to server
      body.each { |part| html += Columbo::Compressor.unzip(part, headers['Content-Encoding']) }
      # Retrieve plain text body for full text search
      text, title = to_plain_text(html)
      # Get request headers
      request_headers = {}
      request.env.each { |key, value| request_headers[key.sub(/^HTTP_/, '').downcase] = value if key.start_with? 'HTTP_'}
      data = {
          uuid: cookie,
          request: {
              params: request.params,
              remote_ip: request.ip,
              user_agent: request.user_agent,
              method: request.env['REQUEST_METHOD'],
              uri: request.env['REQUEST_URI'],
              script: request.env['SCRIPT_NAME'],
              path: request.env['PATH_INFO'],
              query_string: request.env['QUERY_STRING'],
              protocol: request.env['rack.url_scheme'],
              server_name: request.env['SERVER_NAME'],
              server_port: request.env['SERVER_PORT'],
              http: request.env['SERVER_PROTOCOL'],
              session: request.env['rack.session'],
              cookie: request.env['rack.request.cookie_hash'],
              path_parameters: request.env['action_dispatch.request.path_parameters'],
              headers: request_headers
          },
          response: {
              status: status,
              headers: headers,
              size: html.length,
              body: HtmlMini.minify(html),
              text: text,
              title: title,
              start: start,
              stop: stop,
              time: stop-start
          }
      }
      # Send data to API
      @client.post_data data
    end

    def to_plain_text(html)
      html_doc = Nokogiri::HTML(html)
      html_doc.xpath('//script').each {|node| node.remove}
      html_doc.xpath('//style').each {|node| node.remove}
      text = ''
      html_doc.xpath('//body').each {|node| text += node.text.gsub(/\s{2,}/, ' ')}
      title_tag = html_doc.xpath('//title').first
      title = title_tag.nil? ? nil : title_tag.text
      [text, title]
    end

  end
end