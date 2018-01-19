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
  # Client class for ArcGIS Server administrative directory API.
  #
  class ServerAdminClient
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
      Utils.wait_until_url_available(@server_url + '/')
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
        return true if JSON.parse(response.body)['code'].to_i == 499
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

    def local_machine_name
      uri = URI.parse(@server_url + '/admin/local')

      token = generate_token()

      uri.query = URI.encode_www_form('token' => token,
                                      'f' => 'json')

      request = Net::HTTP::Get.new(uri.request_uri)
      request.add_field('Referer', 'referer')

      response = send_request(request, @server_url)

      validate_response(response)

      JSON.parse(response.body)['machineName']
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
               JSON.parse(response.body)['upgradeStatus'] == 'LAST_ATTEMPT_FAILED'
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
                    config_store_type,
                    config_store_connection_string,
                    config_store_connection_secret,
                    log_level,
                    log_dir,
                    max_log_file_age)
      config_store_connection = {
        'type' => config_store_type,
        'connectionString' => config_store_connection_string,
        'connectionSecret' => config_store_connection_secret
      }

      directories = { 'directories' => [{
        'name' => 'arcgiscache',
        'physicalPath' => ::File.join(server_directories_root, 'directories', 'arcgiscache'),
        'directoryType' => 'CACHE',
        'cleanupMode' => 'NONE',
        'maxFileAge' => 0,
        'description' => 'Stores tile caches used by map, globe, and image services for rapid performance.'
      }, {
        'name' => 'arcgisjobs',
        'physicalPath' => ::File.join(server_directories_root, 'directories', 'arcgisjobs'),
        'directoryType' => 'JOBS',
        'cleanupMode' => 'TIME_ELAPSED_SINCE_LAST_MODIFIED',
        'maxFileAge' => 360,
        'description' => 'Stores results and other information from geoprocessing services.'
      }, {
        'name' => 'arcgisoutput',
        'physicalPath' => ::File.join(server_directories_root, 'directories', 'arcgisoutput'),
        'directoryType' => 'OUTPUT',
        'cleanupMode' => 'TIME_ELAPSED_SINCE_LAST_MODIFIED',
        'maxFileAge' => 10,
        'description' => 'Stores various information generated by services, such as map images.'
      }, {
        'name' => 'arcgissystem',
        'physicalPath' => ::File.join(server_directories_root, 'directories', 'arcgissystem'),
        'directoryType' => 'SYSTEM',
        'cleanupMode' => 'NONE',
        'maxFileAge' => 0,
        'description' => 'Stores directories and files used internally by ArcGIS Server.'
      }] }

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
                            'settings' => log_settings.to_json,
                            'cluster' => '',
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

    def add_machine_to_cluster(machine_name, cluster)
      request = Net::HTTP::Post.new(URI.parse(
        @server_url + "/admin/clusters/#{cluster}/machines/add").request_uri)
      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('username' => @admin_username,
                            'password' => @admin_password,
                            'machineNames' => machine_name,
                            'token' => token,
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def ssl_certificate_exist?(machine_name, cert_alias)
      request = Net::HTTP::Post.new(URI.parse(@server_url +
        "/admin/machines/#{machine_name}/sslcertificates/#{cert_alias}").request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('token' => token, 'f' => 'json')

      response = send_request(request, @server_url)

      JSON.parse(response.body)['Alias name'] == cert_alias
    end

    def import_server_ssl_certificate(machine_name, cert_file, cert_password, cert_alias)
      begin
        require 'net/http/post/multipart'
      rescue LoadError
        Chef::Log.error("Missing gem 'multipart-post'. Use the 'system' recipe to install it first.")
      end

      url = URI.parse(@server_url + 
        "/admin/machines/#{machine_name}/sslcertificates/importExistingServerCertificate")

      token = generate_token()

      request = Net::HTTP::Post::Multipart.new url.path,
        'certFile' => UploadIO.new(File.new(cert_file), 'application/x-pkcs12', cert_alias),
        'certPassword' => cert_password,
        'alias' => cert_alias,
        'token' => token,
        'f' => 'json'

      request.add_field('Referer', 'referer')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def machine_info(machine_name)
      request = Net::HTTP::Post.new(URI.parse(@server_url +
        "/admin/machines/#{machine_name}").request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('token' => token, 'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)

      JSON.parse(response.body)
    end

    def get_server_ssl_certificate(machine_name)
      machine_info(machine_name)['webServerCertificateAlias']
    end

    def set_server_ssl_certificate(machine_name, cert_alias)
      machine = machine_info(machine_name)

      request = Net::HTTP::Post.new(URI.parse(@server_url +
        "/admin/machines/#{machine_name}/edit").request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data(
        'machineName' => machine_name,
        'adminURL' => machine['adminURL'],
        'webServerMaxHeapSize' => machine['webServerMaxHeapSize'],
        'webServerCertificateAlias' => cert_alias,
        'appServerMaxHeapSize' => machine['appServerMaxHeapSize'],
        'socMaxHeapSize' => machine['socMaxHeapSize'],
        'OpenEJBPort' => machine['ports']['OpenEJBPort'],
        'JMXPort' => machine['ports']['JMXPort'],
        'NamingPort' => machine['ports']['NamingPort'],
        'DerbyPort' => machine['ports']['DerbyPort'],
        'token' => token,
        'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def get_server_admin_url(machine_name)
      machine_info(machine_name)['adminURL']
    end

    def set_server_admin_url(machine_name, admin_url)
      machine = machine_info(machine_name)

      request = Net::HTTP::Post.new(URI.parse(@server_url +
        "/admin/machines/#{machine_name}/edit").request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data(
        'machineName' => machine_name,
        'adminURL' => admin_url,
        'webServerMaxHeapSize' => machine['webServerMaxHeapSize'],
        'webServerCertificateAlias' => machine['webServerCertificateAlias'],
        'appServerMaxHeapSize' => machine['appServerMaxHeapSize'],
        'socMaxHeapSize' => machine['socMaxHeapSize'],
        'OpenEJBPort' => machine['ports']['OpenEJBPort'],
        'JMXPort' => machine['ports']['JMXPort'],
        'NamingPort' => machine['ports']['NamingPort'],
        'DerbyPort' => machine['ports']['DerbyPort'],
        'token' => token,
        'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def register_database(data_item_path, connection_string, is_managed)
      return if connection_string.nil? || connection_string.empty?

      request = Net::HTTP::Post.new(
        URI.parse(@server_url + '/admin/data/registerItem').request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      item = {
        'path' => data_item_path,
        'type' => 'egdb',
        'clientPath' => nil,
        'info' => {
          'isManaged' => is_managed,
          'dataStoreConnectionType' => 'serverOnly',
          'connectionString' => connection_string
        }
      }

      request.set_form_data('item' => item.to_json,
                            'token' => token,
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def federate(portal_url, portal_token, server_id, secret_key)
      request = Net::HTTP::Post.new(
        URI.parse(@server_url + '/admin/security/config/update').request_uri)
      request.add_field('Referer', 'referer')

      token = generate_token()

      security_config = {
        'securityEnabled' => true,
        'authenticationMode' => 'ARCGIS_PORTAL_TOKEN',
        'authenticationTier' => 'ARCGIS_PORTAL',
        'userStoreConfig' => {
          'type' => 'PORTAL'
        },
        'sslEnabled' => true,
        'httpEnabled' => true,
        'virtualDirsSecurityEnabled' => true,
        'portalProperties' => {
          'portalUrl' => portal_url,
          'privatePortalUrl' => portal_url,
          'portalSecretKey' => secret_key,
          'portalMode' => 'ARCGIS_PORTAL_FEDERATION',
          'serverId' => server_id,
          'serverUrl' => @server_url,
          'token' => portal_token,
          'referer' => 'referer'
        },
        'allowDirectAccess' => true }

      request.set_form_data('token' => token,
                            'securityConfig' => security_config.to_json,
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)

      sleep(180.0)

      # Federate services
      wait_until_available

      request = Net::HTTP::Post.new(@server_url + '/admin/services/federate')
      request.add_field('Referer', 'referer')
      request.set_form_data('token' => portal_token,
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

    def upload_item(item_file, description)
      begin
        require 'net/http/post/multipart'
      rescue LoadError
        Chef::Log.error("Missing gem 'multipart-post'. Use the 'system' recipe to install it first.")
      end

      return if item_file.nil? || item_file.empty?

      request = Net::HTTP::Post.new(URI.parse(@server_url + '/admin/uploads/upload').request_uri)

      url = URI.parse(@server_url + '/admin/uploads/upload')

      token = generate_token()

      request = Net::HTTP::Post::Multipart.new url.path,
        'itemFile' => UploadIO.new(File.new(item_file), 'application/octet-stream', File.basename(item_file)),
        'description' => description,
        'token' => token,
        'f' => 'json'

      request.add_field('Referer', 'referer')

      response = send_request(request, @server_url)

      validate_response(response)

      JSON.parse(response.body)['item']['itemID']
    end

    def extract_item_file(item_id, filename)
      uri = URI.parse(@server_url + "/admin/uploads/#{item_id}/#{filename}")

      token = generate_token()

      uri.query = URI.encode_www_form('token' => token, 'f' => 'json')

      request = Net::HTTP::Get.new(uri.request_uri)
      request.add_field('Referer', 'referer')

      response = send_request(request, @server_url)

      response.body
    end

    def service_exists?(service_name)
      return false if service_name.nil? || service_name.empty?

      request = Net::HTTP::Post.new(URI.parse(@server_url +
        '/admin/services/' + service_name).request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('token' => token, 'f' => 'json')

      response = send_request(request, @server_url)

      begin
        validate_response(response)
        return true
      rescue Exception => ex
        return false
      end
    end

    def start_service(service_name)
      return if service_name.nil? || service_name.empty?

      request = Net::HTTP::Post.new(URI.parse(@server_url + '/admin/services/' +
        service_name + '/start').request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('token' => token, 'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def stop_service(service_name)
      return if service_name.nil? || service_name.empty?

      request = Net::HTTP::Post.new(URI.parse(@server_url + '/admin/services/' +
        service_name + '/stop').request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('token' => token, 'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def delete_service(service_name)
      return if service_name.nil? || service_name.empty?

      request = Net::HTTP::Post.new(URI.parse(@server_url + '/admin/services/' +
        service_name + '/delete').request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('token' => token, 'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def update_system_properties(properties)
      request = Net::HTTP::Post.new(URI.parse(@server_url + '/admin/system/properties/update').request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('properties' => properties.to_json,
                            'token' => token, 
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def set_identity_store(user_store_config, role_store_config)
      request = Net::HTTP::Post.new(URI.parse(@server_url + '/admin/security/config/updateIdentityStore').request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('userStoreConfig' => user_store_config.to_json,
                            'roleStoreConfig' => role_store_config.to_json,
                            'token' => token, 
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    def assign_privileges(rolename, privilege)
      request = Net::HTTP::Post.new(URI.parse(@server_url + '/admin/security/roles/assignPrivilege').request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token()

      request.set_form_data('rolename' => rolename,
                            'privilege' => privilege,
                            'token' => token, 
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)
    end

    # TODO: Support setting webServerMaxHeapSize, appServerMaxHeapSize, and 
    # other machine properties here.
    def set_machine_properties(machine_name, soc_max_heap_size)
      # for updating SOC Max Heap Size, all configuration parameters (ports, etc.) have to be
      # passed to the corresponding REST interface. Though, the current configuration is
      # retrieved first to pass it later together with the new SOC Max Heap Size.

      machine = machine_info(machine_name)

      if machine['socMaxHeapSize'].to_i != soc_max_heap_size
        request = Net::HTTP::Post.new(URI.parse(@server_url +
          "/admin/machines/#{machine_name}/edit").request_uri)

        request.add_field('Referer', 'referer')

        token = generate_token()

        request.set_form_data(
          'machineName' => machine_name,
          'adminURL' => machine['adminURL'],
          'webServerMaxHeapSize' => machine['webServerMaxHeapSize'],
          'webServerCertificateAlias' => machine['webServerCertificateAlias'],
          'appServerMaxHeapSize' => machine['appServerMaxHeapSize'],
          'socMaxHeapSize' => soc_max_heap_size,
          'OpenEJBPort' => machine['ports']['OpenEJBPort'],
          'JMXPort' => machine['ports']['JMXPort'],
          'NamingPort' => machine['ports']['NamingPort'],
          'DerbyPort' => machine['ports']['DerbyPort'],
          'token' => token,
          'f' => 'json')

        response = send_request(request, @server_url)

        validate_response(response)

        return true
      end

      return false
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
          if error_info['status'] == 'error'
            raise error_info['messages'].join(' ')
          end
        end
      end
    end
  end
end
