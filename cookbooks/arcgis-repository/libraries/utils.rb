#
# Copyright 2018 Esri
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

#
# ArcGIS helper classes
#
module ArcGIS
  # Retrieves ArcGIS software download URL from remote ArcGIS Software repository.
  def self.get_download_url(repository_url, access_key, file, subfolder)
    uri = URI.parse(repository_url + '/' + file)

    uri.query = URI.encode_www_form('token' => access_key,
                                    'folder' => subfolder)

    request = Net::HTTP::Get.new(uri.request_uri)

    response = send_request(repository_url, request)

    validate_response(response)

    JSON.parse(response.body)['url']
  end

  def self.send_request(repository_url, request)
    uri = URI.parse(repository_url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 3600

    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    Chef::Log.debug("Request: #{request.method} #{uri.scheme}://#{uri.host}:#{uri.port}#{request.path}")

    Chef::Log.debug(request.body) unless request.body.nil?

    response = http.request(request)

    if [301, 302].include? response.code.to_i
      Chef::Log.debug("Moved to: #{response.header['location']}")

      uri = URI.parse(response.header['location'])

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 3600

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      if request.method == 'POST'
        body = request.body
        request = Net::HTTP::Post.new(URI.parse(response.header['location']).request_uri)
        request.body = body
      else
        request = Net::HTTP::Get.new(URI.parse(response.header['location']).request_uri)
      end

      request.add_field('Referer', 'referer')

      response = http.request(request)
    end

    Chef::Log.debug("Response: #{response.code} #{response.body}")

    response
  end

  def self.validate_response(response)
    if response.code.to_i >= 300
      raise response.message
    elsif response.code.to_i == 200
      error_info = JSON.parse(response.body)
      raise error_info['message'] unless error_info['code'] == 200
    end
  end
end
