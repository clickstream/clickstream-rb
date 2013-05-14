require 'net/http'
require 'json'

module Columbo
  class APIClient

    API_URI     = "http://localhost:15080/hit".freeze

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
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.post(@api_uri, payload, headers)
        zlib.unzip(response.body, response['Content-Encoding'])
      end
    end

  end
end
