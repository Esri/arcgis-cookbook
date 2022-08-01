#
# Copyright 2021 Esri
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
  # Client class for ArcGIS Software repository.
  #
  class RepositoryClient

    @repository_url = nil
    @username = nil
    @password = nil

    def initialize(repository_url, username, password)
      @repository_url = repository_url
      @username = username
      @password = password
    end

    def info
      uri = URI.parse(@repository_url + '/repository/info')

      request = Net::HTTP::Get.new(uri.request_uri)

      response = send_request(request, @repository_url)

      validate_response(response)

      JSON.parse(response.body)
    end

    def files(folder)
      uri = URI.parse(@repository_url + '/repository')

      request = Net::HTTP::Get.new(uri.request_uri)

      uri.query = URI.encode_www_form('folder' => folder)

      response = send_request(request, @repository_url)

      validate_response(response)

      JSON.parse(response.body)
    end

    def generate_url(files, folder = nil)
      uri = URI.parse(@repository_url + '/repository/generateUrl')

      request = Net::HTTP::Post.new(URI.parse(@repository_url + '/repository/generateUrl').request_uri)

      token = generate_token()

      request.add_field('Authorization', 'Bearer ' + token)

      request.set_form_data('file' => files, 'folder' => folder)

      response = send_request(request, @repository_url)

      validate_response(response)

      JSON.parse(response.body)
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
      if response.code.to_i > 200
        error_info = JSON.parse(response.body)
        raise error_info['message']
      end
    end

    def generate_token()
      token_service_url = info['authInfo']['tokenServicesUrl']

      request = Net::HTTP::Post.new(URI.parse(token_service_url).request_uri)

      request.set_form_data('username' => @username,
                            'password' => @password,
                            'client' => 'referer',
                            'referer' => 'referer',
                            'expiration' => '600',
                            'f' => 'json')

      response = send_request(request, token_service_url)

      validate_response(response)

      JSON.parse(response.body)['token']
    end
  end
end