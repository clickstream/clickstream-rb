require 'net/http'
require 'json'

module Clickstream
  class APIClient

    API_URI = 'https://clickstream-api.herokuapp.com'.freeze

    def initialize(api_key, api_uri)
      @api_key = api_key
      @api_uri = api_uri || API_URI
    end

    def handshake
      Thread.new do
        headers = { "Content-Type" => "application/json; charset=utf-8" }

        uri = URI(@api_uri + '/' + @api_key + '/handshake')
        Net::HTTP.new(uri.host, uri.port).start do |http|
          response = http.get(uri.request_uri, headers)
          json = JSON.parse(response.body)
          json.each { |k, v| yield k, v }
        end
      end
    end

    def post_data(hash)
      headers = {
          "Accept-Encoding" => "gzip, deflate",
          "Content-Encoding" => "deflate",
          "Content-Type" => "application/json; charset=utf-8"
      }

      zlib = Clickstream::Compressor
      json = hash.merge({api_key: @api_key}).to_json
      payload = zlib.deflate(json)
      uri = URI(@api_uri + '/' + @api_key + '/capture')

      start = Time.now
      Net::HTTP.new(uri.host, uri.port).start do |http|
        response = http.post(uri.request_uri, payload, headers)
        stop = Time.now
        duration = ((stop-start) * 1000).round(3)
        zlib.unzip(response.body, response['Content-Encoding']) + ' - Time: ' + duration.to_s + 'ms'
      end
    end

  end
end
