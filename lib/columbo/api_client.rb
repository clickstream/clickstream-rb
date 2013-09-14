require 'net/http'
require 'json'

module Columbo
  class APIClient

    API_URI     = "http://localhost:15080/capture".freeze
    #API_URI     = "http://columbo.aws.af.cm/capture".freeze

    def initialize(api_key, api_uri)
      @api_key = api_key
      @api_uri = api_uri || API_URI
    end

    def post_data(hash)

      zlib = Columbo::Compressor

      headers = {
          "Accept-Encoding" => "gzip, deflate",
          "Content-Encoding" => "deflate",
          "Content-Type" => "application/json; charset=utf-8"
      }

      json = hash.merge({api_key: @api_key}).to_json
      payload = zlib.deflate(json)

      uri = URI(@api_uri)

      start = Time.now
      Net::HTTP.new(uri.host, uri.port).start do |http|
        response = http.post(@api_uri, payload, headers)

        stop = Time.now
        duration = ((stop-start) * 1000).round(3)
        zlib.unzip(response.body, response['Content-Encoding']) + ' - Time: ' + duration.to_s + 'ms'
      end
    end

  end
end
