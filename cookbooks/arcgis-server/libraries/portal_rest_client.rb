#
# Copyright 2015 Esri
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
  #
  # Client class for Portal for ArcGIS REST Directory client.
  #
  class PortalRestClient

    @portal_url = nil
    @username = nil
    @password = nil

    def initialize(portal_url, username, password)
      @portal_url = portal_url
      @username = username
      @password = password
    end

    def wait_until_available
      Utils.wait_until_url_available(@portal_url + '/sharing/rest/info?f=json')
    end

    def available?
      uri = URI.parse(@portal_url + '/sharing/rest/info?f=json')

      request = Net::HTTP::Get.new(uri.request_uri)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 3600

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      response = http.request(request)

      response.code.to_i == 200
    end

  end
end
