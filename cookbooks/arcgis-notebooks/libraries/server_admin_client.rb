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
require 'securerandom'

#
# ArcGIS helper classes
#
module ArcGIS
  #
  # Client class for ArcGIS Notebook Server administrative directory API.
  #
  class NotebookServerAdminClient
    MAX_RETRIES = 300
    SLEEP_TIME = 10.0

    @server_url = nil
    @admin_username = nil
    @admin_password = nil
    @generate_token_url = nil
    @token = nil

    def initialize(server_url, admin_username, admin_password, token = nil)
      @server_url = server_url
      @admin_username = admin_username
      @admin_password = admin_password
      @generate_token_url = server_url + '/admin/generateToken'
      @token = token
    end

    def generate_token_url=(generate_token_url)
      @generate_token_url = generate_token_url
    end

    def wait_until_available
      Utils.wait_until_url_available(@server_url + '/admin/?f=json')
    end

    def site_exist?
      uri = URI.parse(@server_url + '/admin/?f=json')

      request = Net::HTTP::Get.new(uri.request_uri)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 3600

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      response = http.request(request)

      if response.code.to_i == 200
        json = JSON.parse(response.body)
        return true if json.has_key?('error') && json['error']['code'].to_i == 499
      end

      false
    end

    def wait_until_site_exist
      count = 0
      MAX_RETRIES.times do
        if site_exist?
          count += 1
          break if count >= 3
        end

        sleep(SLEEP_TIME)
      end
    end

    def info
      uri = URI.parse(@server_url + '/rest/info')

      uri.query = URI.encode_www_form('f' => 'json')

      request = Net::HTTP::Get.new(uri.request_uri)
      request.add_field('Referer', 'referer')

      response = send_request(request, @server_url)

      if response.code.to_i >= 300
        raise response.message
      elsif response.code.to_i == 200
        error_info = JSON.parse(response.body)
        raise error_info['error']['message'] unless error_info['error'].nil?
      end

      JSON.parse(response.body)
    end

    def upgrade_required?
      uri = URI.parse(@server_url + '/admin/upgrade?f=json')

      request = Net::HTTP::Get.new(uri.request_uri)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 3600

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      response = http.request(request)

      if response.code.to_i == 200
        return JSON.parse(response.body)['upgradeStatus'] == 'UPGRADE_REQUIRED' ||
               JSON.parse(response.body)['upgradeStatus'] == 'LAST_ATTEMPT_FAILED' ||
               JSON.parse(response.body)['isUpgrade'] # Notebook Server
      end

      false
    end

    def complete_upgrade
      request = Net::HTTP::Post.new(URI.parse(
        @server_url + '/admin/upgrade').request_uri)

      request.set_form_data('f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def create_site(server_directories_root,
                    workspace,
                    config_store_type,
                    config_store_connection_string,
                    config_store_class_name,
                    log_level,
                    log_dir,
                    max_log_file_age)
      config_store_connection = {
        'configPersistenceType' => config_store_type,
        'connectionString' => config_store_connection_string,
        'className' => config_store_class_name
      }

      directories = [{
        'path' => ::File.join(server_directories_root, 'directories', 'arcgisoutput'),
        'name' => 'arcgisoutput',
        'id' => SecureRandom.uuid,
        'type' => 'OUTPUT'
      }, {
        'path' => workspace,
        'name' => "arcgisworkspace",
        'id' => SecureRandom.uuid,
        'type' => 'WORKSPACE'
      }, {
        'path' => ::File.join(server_directories_root, 'directories', 'arcgissystem'),
        'name' => 'arcgissystem',
        'id' => SecureRandom.uuid,
        'type' => 'SYSTEM'
      }, {
        'path' => ::File.join(server_directories_root, 'directories', 'arcgisjobs'),
        'name' => 'arcgisjobs',
        'id' => SecureRandom.uuid,
        'type' => 'JOBS'
      }]

      log_settings = {
        'logLevel' => log_level,
        'logDir' => log_dir,
        'maxErrorReportsCount' => 10,
        'maxLogFileAge' => max_log_file_age }

      request = Net::HTTP::Post.new(URI.parse(
        @server_url + '/admin/createNewSite').request_uri)

      request.set_form_data('username' => @admin_username,
                            'password' => @admin_password,
                            'configStoreConnection' => config_store_connection.to_json,
                            'directories' => directories.to_json,
                            'logsSettings' => log_settings.to_json,
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def join_site(primary_server_url)
      request = Net::HTTP::Post.new(URI.parse(
        @server_url + '/admin/joinSite').request_uri)

      request.set_form_data('username' => @admin_username,
                            'password' => @admin_password,
                            'adminURL' => primary_server_url + '/admin',
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def generate_token()
      return @token if !@token.nil?

      request = Net::HTTP::Post.new(URI.parse(@generate_token_url).request_uri)

      request.set_form_data('username' => @admin_username,
                            'password' => @admin_password,
                            'client' => 'referer',
                            'referer' => 'referer',
                            'expiration' => '600',
                            'f' => 'json')

      response = send_request(request, @generate_token_url)

      validate_response(response)

      JSON.parse(response.body)['token']
    end

    def system_properties
      request = Net::HTTP::Post.new(URI.parse(@server_url + '/admin/system/properties').request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('token' => token, 
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)

      JSON.parse(response.body)
    end

    def update_system_properties(new_properties)
      properties = system_properties.merge(new_properties)

      request = Net::HTTP::Post.new(URI.parse(@server_url + '/admin/system/properties/update').request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('properties' => properties.to_json,
                            'token' => token, 
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def machines
      request = Net::HTTP::Post.new(URI.parse(@server_url +
        "/admin/machines").request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('token' => token, 'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)

      JSON.parse(response.body)['machines']
    end

    def unregister_machine(machine_name)
      request = Net::HTTP::Post.new(URI.parse(@server_url +
        "/admin/machines/#{machine_name}/unregister").request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('token' => token, 'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def remove_machine_from_cluster(machine_name, cluster = 'default')
      request = Net::HTTP::Post.new(URI.parse(@server_url +
        "/admin/clusters/#{cluster}/machines/remove").request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data(
        'machineNames' => machine_name,
        'token' => token,
        'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def unregister_web_adaptor(id)
      request = Net::HTTP::Post.new(URI.parse(@server_url +
        "/admin/system/webadaptors/#{id}/unregister").request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('token' => token, 'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def unregister_web_adaptors
      request = Net::HTTP::Post.new(URI.parse(@server_url +
        "/admin/system/webadaptors").request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('token' => token, 'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)

      web_adaptors = JSON.parse(response.body)['webAdaptors']

      web_adaptors.each do |web_adaptor|
        unregister_web_adaptor(web_adaptor['id'])
      end
    end

    private

    def send_request(request, url)
      uri = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 3600

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      Chef::Log.debug("Request: #{request.method} #{uri.scheme}://#{uri.host}:#{uri.port}#{request.path}")

      Chef::Log.debug(request.body) unless request.body.nil?

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
      if response.code.to_i == 301
        raise 'Moved permanently to ' + response.header['location']
      elsif response.code.to_i > 300
        raise response.message
      else
        if response.code.to_i == 200
          error_info = JSON.parse(response.body)
          if error_info.has_key?('error')
            raise error_info['error']['message']
          end
        end
      end
    end
  end
end
