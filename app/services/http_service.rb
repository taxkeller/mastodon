#frozen_string_literal: true

require 'net/http'
require 'uri'

class HttpService < BaseService
  def call(uri, method = 'get', params = {})
    if method == 'get'
      uri = URI(uri)
      res = Net::HTTP.get_response(uri)
    else
      uri = URI.parse(uri)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true

      req = Net::HTTP::Post.new(uri.request_uri)
      req["Content-Type"] = "application/json”"
      req.body = params.to_json
      res = https.request(req)
    end
    res
  end
end
