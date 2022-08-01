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
  # Client class for ArcGIS Downloads API.
  #
  class DownloadsAPIClient

    @downloads_service_url = nil

    def initialize(downloads_service_url)
      @downloads_service_url = downloads_service_url
    end

    def generate_url(file, folder, token)
      if token.nil?
        raise "Repository access credentials are not specified."
      end

      uri = URI.parse(@downloads_service_url + '/dms/rest/download/secured/' + file)

      uri.query = URI.encode_www_form('folder' => folder, 'token' => token)

      request = Net::HTTP::Get.new(uri.request_uri)

      request.add_field('Referer', 'referer')

      response = send_request(request, @downloads_service_url)

      validate_response(response)

      JSON.parse(response.body)['url']
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
    end
  end

end
