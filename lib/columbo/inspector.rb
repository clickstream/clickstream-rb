require 'rack/request'
require 'rack/response'
require 'nokogiri'
require 'html_mini'

module Columbo
  class Inspector

    def initialize(mongo_uri)
      @mongo_uri = mongo_uri
    end

    def investigate(env, status, headers, body, start, stop)
      # Lazy connection to MongoDB
      client = Columbo::DbClient.new @mongo_uri
      # Normalise request from env
      request = Rack::Request.new(env)
      html = ''
      body.each { |part| html += part }
      # Retrieve plain text body for full text search
      text, title = to_plain_text(html)
      # Get request headers
      request_headers = {}
      request.env.each { |key, value| request_headers[key.sub(/^HTTP_/, '').downcase] = value if key.start_with? 'HTTP_'}
      # Convert MIME types into String
      formats = request.env['action_dispatch.request.formats'].collect {|format| format.to_s}
      data = {
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
              formats: formats,
              path_parameters: request.env['action_dispatch.request.path_parameters'],
              headers: request_headers
          },
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
      # Insert data in MongoDB
      client.insert sanitize(data)
    end

    def to_plain_text(html)
      html_doc = Nokogiri::HTML(html)
      html_doc.xpath('//script').each {|node| node.remove}
      html_doc.xpath('//style').each {|node| node.remove}
      text = ''
      html_doc.xpath('//body').each {|node| text += node.text.gsub(/\s{2,}/, ' ')}
      title = html_doc.xpath('//title').first.text
      [text, title]
    end
    
    private

    def sanitize(data)
      Hash[
        data.map do |key, value|
          value = sanitize(value) if value.is_a? Hash
          # replace $ and . in keys by Unicode full width equivalent
          # http://docs.mongodb.org/manual/faq/developers/#faq-dollar-sign-escaping
          key = key.gsub('.', 'U+FF0E').gsub('$', 'U+FF04') if key.is_a? String
          # transform symbol into string to avoid auto transformation into $symbol
          value = value.to_s if value.is_a? Symbol
          [key, value]
        end
      ]
    end

  end
end