#
# Copyright 2022 Esri
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'net/http'
require 'uri'
require 'json'

module ArcGIS
  #
  # Client class for ArcGIS Online token service client.
  #
  class TokenServiceClient

    @token_service_url = nil

    def initialize(token_service_url)
      @token_service_url = token_service_url
    end

    def generate_token(username, password, referer = 'referer', expiration = 600)
      request = Net::HTTP::Post.new(URI.parse(@token_service_url).request_uri)

      request.set_form_data('username' => username,
                            'password' => password,
                            'client' => 'referer',
                            'referer' => referer,
                            'expiration' => expiration.to_s,
                            'f' => 'json')

      response = send_request(request, @token_service_url)

      validate_response(response)

      JSON.parse(response.body)['token']
    end

    private

    def send_request(request, url)
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)

      http.read_timeout = 600
      http.use_ssl = true

      Chef::Log.debug("Request: #{request.method} #{uri.scheme}://#{uri.host}:#{uri.port}#{request.path}")

      Chef::Log.debug(request.body) unless request.body.nil?

      response = http.request(request)

      Chef::Log.debug("Response: #{response.code} #{response.body}")

      response
    end

    def validate_response(response)
      error_info = JSON.parse(response.body)
      raise error_info['message'] if response.code.to_i > 200
      raise error_info['error']['message'] unless error_info['error'].nil?
    end
  end
 
end
