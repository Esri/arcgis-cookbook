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

#
# ArcGIS helper classes
#
module ArcGIS
  #
  # Client class for ArcGIS Server REST API.
  #
  class ServerRestClient

    @server_url = nil
    @username = nil
    @password = nil

    def initialize(server_url, username, password)
      @server_url = server_url
      @username = username
      @password = password
    end

    def wait_until_available
      Utils.wait_until_url_available(@server_url + '/rest/info?f=json')
    end

    def available?
      uri = URI.parse(@server_url + '/rest/info?f=json')

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

    def info
      uri = URI.parse(@server_url + '/rest/info')

      uri.query = URI.encode_www_form('f' => 'json')

      request = Net::HTTP::Get.new(uri.request_uri)
      request.add_field('Referer', 'referer')

      response = send_request(request, @server_url)

      validate_response(response)

      JSON.parse(response.body)
    end

    def publish_service_definition(uploaded_item_id, config_overwrite, publish_options)
      tool = '/rest/services/System/PublishingTools/GPServer/Publish%20Service%20Definition'
      request = Net::HTTP::Post.new(URI.parse(@server_url + tool + '/submitJob').request_uri)
      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('in_sdp_id' => uploaded_item_id,
                            'in_config_overwrite' => config_overwrite.to_json,
                            'in_publish_options' => publish_options.to_json,
                            'token' => token,
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)

      job_id = JSON.parse(response.body)['jobId']

      request = Net::HTTP::Post.new(URI.parse(@server_url + tool + '/jobs/' + job_id).request_uri)
      request.add_field('Referer', 'referer')

      request.set_form_data('token' => token, 'f' => 'json')

      while true do 
        response = send_request(request, @server_url)
  
        validate_response(response)
  
        job_status = JSON.parse(response.body)['jobStatus']

        break if job_status != 'esriJobExecuting' && job_status != 'esriJobSubmitted'

        raise 'Failed to publish service.' if job_status == 'esriJobFailed'

        sleep(10)
      end
    end

    def add_service_permission(service, service_type, role)
      uri = URI.parse(@server_url + '/admin/services/' + service + '.' + service_type + '/permissions/add')
      request = Net::HTTP::Post.new(uri.request_uri)
      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('principal' => role,
                            'isAllowed' => 'true',
                            'token' => token,
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def clean_service_permissions(role)
      uri = URI.parse(@server_url + '/admin/services/permissions/clean')
      request = Net::HTTP::Post.new(uri.request_uri)
      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('principal' => role,
                            'token' => token,
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def upload_service_item(service, service_type, item_folder, item_file)
      begin
        require 'net/http/post/multipart'
      rescue LoadError
        Chef::Log.error("Missing gem 'multipart-post'. Use the 'system' recipe to install it first.")
      end

      return if item_file.nil? || item_file.empty?

      url = URI.parse(@server_url + '/admin/services/' + service + '.' + service_type + '/iteminfo/upload')
      request = Net::HTTP::Post.new(url.request_uri)

      token = generate_token()

      request = Net::HTTP::Post::Multipart.new url.path,
        'folder' => item_folder,
        'file' => UploadIO.new(File.new(item_file), 'application/octet-stream', File.basename(item_file)),
        'token' => token,
        'f' => 'json'

      request.add_field('Referer', 'referer')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def get_database_connection_string(uploaded_connection_file_id)
      tool = '/rest/services/System/PublishingTools/GPServer/Get%20Database%20Connection%20String'
      request = Net::HTTP::Post.new(URI.parse(@server_url + tool + '/submitJob').request_uri)
      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('in_connDataType' => 'UPLOADED_CONNECTION_FILE_ID',
                            'in_inputData' => uploaded_connection_file_id,
                            'token' => token,
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)

      job_id = JSON.parse(response.body)['jobId']

      request = Net::HTTP::Post.new(URI.parse(@server_url + tool + '/jobs/' + job_id).request_uri)
      request.add_field('Referer', 'referer')
      request.set_form_data('token' => token, 'f' => 'json')

      while true do
        response = send_request(request, @server_url)
  
        validate_response(response)
  
        job_status = JSON.parse(response.body)['jobStatus']

        break if job_status != 'esriJobExecuting' && job_status != 'esriJobSubmitted'

        raise 'Failed to get database connection string.' if job_status == 'esriJobFailed'

        sleep(10)
      end

      request = Net::HTTP::Post.new(URI.parse(@server_url + tool + '/jobs/' +
                                    job_id + '/results/out_connectionString').request_uri)
      request.add_field('Referer', 'referer')
      request.set_form_data('token' => token, 'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)

      JSON.parse(response.body)['value']
    end

    def generate_token()
      generate_token_url = info['authInfo']['tokenServicesUrl']

      if generate_token_url.empty?
        generate_token_url = info['owningSystemUrl'] + '/sharing/rest/generateToken'
      end

      request = Net::HTTP::Post.new(URI.parse(generate_token_url).request_uri)

      request.set_form_data('username' => @username,
                            'password' => @password,
                            'client' => 'referer',
                            'referer' => 'referer',
                            'expiration' => '600',
                            'f' => 'json')

      response = send_request(request, generate_token_url, true)

      validate_response(response)

      JSON.parse(response.body)['token']
    end

    private

    def send_request(request, url, sensitive = false)
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 3600

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      Chef::Log.debug("Request: #{request.method} #{uri.scheme}://#{uri.host}:#{uri.port}#{request.path}")

      if sensitive
        Chef::Log.debug("Request body was not logged because it contains sensitive information.") 
      else
        Chef::Log.debug(request.body) unless request.body.nil?
      end

      response = http.request(request)

      if response.code.to_i == 301
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
          request = Net::HTTP::Post.new(URI.parse(
            response.header['location']).request_uri)
          request.body = (body)
        else
          request = Net::HTTP::Get.new(URI.parse(
            response.header['location']).request_uri)
        end

        request.add_field('Referer', 'referer')

        response = http.request(request)
      end

      Chef::Log.debug("Response: #{response.code} #{response.body}")

      response
    end

    def validate_response(response)
      if response.code.to_i >= 300
        raise response.message
      elsif response.code.to_i == 200
        error_info = JSON.parse(response.body)
        raise error_info['error']['message'] unless error_info['error'].nil?
      end
    end

  end
end
