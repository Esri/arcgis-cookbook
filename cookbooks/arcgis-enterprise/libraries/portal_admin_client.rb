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
  # Client class for ArcGIS Portal Directory.
  #
  class PortalAdminClient
    MAX_RETRIES = 30
    SLEEP_TIME = 10.0

    @portal_url = nil
    @admin_username = nil
    @admin_password = nil

    def initialize(portal_url, admin_username, admin_password)
      @portal_url = portal_url
      @admin_username = admin_username
      @admin_password = admin_password
    end

    def wait_until_available
      Utils.wait_until_url_available(@portal_url + '/portaladmin')
    end

    def site_exist?
      uri = URI.parse(@portal_url + '/portaladmin/?f=json')

      request = Net::HTTP::Get.new(uri.request_uri)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 3600

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      response = http.request(request)

      if response.code.to_i == 200
        error_info = JSON.parse(response.body)
        return true if !error_info['error'].nil? &&
                       error_info['error']['code'].to_i == 499
      end

      false
    end

    def upgrade_required?
      uri = URI.parse(@portal_url + '/portaladmin/?f=json')

      request = Net::HTTP::Get.new(uri.request_uri)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 3600

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      Chef::Log.debug("Request: #{request.method} #{uri.scheme}://#{uri.host}:#{uri.port}#{request.path}")

      response = http.request(request)

      Chef::Log.debug("Response: #{response.code} #{response.body}")

      if response.code.to_i == 200
        return JSON.parse(response.body)['isUpgrade'] == true
      end

      false
    end

    def complete_upgrade(is_backup_required, is_rollback_required)
      if upgrade_required?
        Chef::Log.info("Completing portal upgrade...")

        request = Net::HTTP::Post.new(URI.parse(@portal_url +
                                      '/portaladmin/upgrade').request_uri)
  
        request.set_form_data('f' => 'json',
                              'isBackupRequired' => is_backup_required,
                              'isRollbackRequired' =>is_rollback_required)
  
        response = send_request(request)
  
        validate_response(response)

        Chef::Log.info("Portal upgrade completed successfully.")

        true
      end

      false
    end

    def post_upgrade_required?
      token = generate_token(@portal_url + '/sharing/generateToken')

      uri = URI.parse(@portal_url + "/portaladmin")

      uri.query = URI.encode_www_form('token' => token, 'f' => 'json')

      request = Net::HTTP::Get.new(uri.request_uri)

      request.add_field('Referer', 'referer')

      response = send_request(request)

      validate_response(response)

      JSON.parse(response.body)['isPostUpgrade']
    end

    def post_upgrade
      if post_upgrade_required?
        Chef::Log.info("Portal post-upgrade...")

        request = Net::HTTP::Post.new(URI.parse(@portal_url +
          "/portaladmin/postUpgrade").request_uri)

        request.add_field('Referer', 'referer')

        token = generate_token(@portal_url + '/sharing/generateToken')

        request.set_form_data(
          'token' => token,
          'f' => 'json')

        response = send_request(request)

        validate_response(response)
      end
    end

    def create_site(admin_email,
                    admin_full_name,
                    admin_description,
                    security_question,
                    security_question_answer,
                    content_store)
      create_site_uri = URI.parse(@portal_url + '/portaladmin/createNewSite')

      request = Net::HTTP::Post.new(create_site_uri.request_uri)

      request.set_form_data('username' => @admin_username,
                            'password' => @admin_password,
                            'email' => admin_email,
                            'fullname' => admin_full_name,
                            'description' => admin_description,
                            'securityQuestion' => security_question,
                            'securityQuestionAns' => security_question_answer,
                            'contentStore' => content_store,
                            'f' => 'json')

      response = send_request(request)

      validate_response(response)
    end

    def join_site(machine_admin_url)
      join_site_uri = URI.parse(@portal_url + '/portaladmin/joinSite')

      request = Net::HTTP::Post.new(join_site_uri.request_uri)

      request.set_form_data('username' => @admin_username,
                            'password' => @admin_password,
                            'machineAdminUrl' => machine_admin_url,
                            'f' => 'json')

      response = send_request(request)

      validate_response(response)
    end

#    {"machines": [
#        {
#            "machineName": "DEV001258.ESRI.COM",
#            "adminURL": "https://dev001258.esri.com:7443/arcgis",
#            "role": "standby"
#        },
#        {
#            "machineName": "DEV001257.ESRI.COM",
#            "adminURL": "https://dev001257.esri.com:7443/arcgis",
#            "role": "primary"
#        }
#    ]}
    def machines
      token = generate_token(@portal_url + '/sharing/generateToken')

      uri = URI.parse(@portal_url + "/portaladmin/machines")

      uri.query = URI.encode_www_form('token' => token, 'f' => 'json')

      request = Net::HTTP::Get.new(uri.request_uri)

      request.add_field('Referer', 'referer')

      response = send_request(request)

      validate_response(response)

      JSON.parse(response.body)['machines']
    end

    def unregister_machine(machine_name)
      request = Net::HTTP::Post.new(URI.parse(@portal_url +
        "/portaladmin/machines/unregister").request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token(@portal_url + '/sharing/generateToken')

      request.set_form_data(
        'machineName' => machine_name,
        'token' => token,
        'f' => 'json')

      response = send_request(request)

      validate_response(response)
    end

    def ssl_certificate_exist?(cert_alias)
      token = generate_token(@portal_url + '/sharing/generateToken')

      uri = URI.parse(@portal_url +
        "/portaladmin/security/sslCertificates/#{cert_alias}")

      uri.query = URI.encode_www_form('token' => token, 'f' => 'json')

      request = Net::HTTP::Get.new(uri.request_uri)

      request.add_field('Referer', 'referer')

      response = send_request(request)

      JSON.parse(response.body)['Alias name'] == cert_alias
    end

    def import_server_ssl_certificate(cert_file, cert_password, cert_alias)
      begin
        require 'net/http/post/multipart'
      rescue LoadError
        Chef::Log.error("Missing gem 'multipart-post'. Use the 'system' recipe to install it first.")
      end

      url = URI.parse(@portal_url + 
        '/portaladmin/security/sslCertificates/importExistingServerCertificate')

      token = generate_token(@portal_url + '/sharing/generateToken')

      request = Net::HTTP::Post::Multipart.new(url.path,
        'file' => UploadIO.new(File.new(cert_file), 'application/x-pkcs12', cert_alias),
        'password' => cert_password,
        'alias' => cert_alias,
        'token' => token,
        'f' => 'json')

      request.add_field('Referer', 'referer')

      response = send_request(request)

      if response.code.to_i == 200
        error_info = JSON.parse(response.body)
        raise error_info['error']['message'] unless error_info['error'].nil?
      end
    end

    def ssl_certificates
      token = generate_token(@portal_url + '/sharing/generateToken')

      uri = URI.parse(@portal_url + "/portaladmin/security/sslCertificates")

      uri.query = URI.encode_www_form('token' => token, 'f' => 'json')

      request = Net::HTTP::Get.new(uri.request_uri)

      request.add_field('Referer', 'referer')

      response = send_request(request)

      JSON.parse(response.body)
    end

    def server_ssl_certificate
      ssl_certificates['webServerCertificateAlias']
    end

    def set_server_ssl_certificate(cert_alias)
      request = Net::HTTP::Post.new(URI.parse(@portal_url +
        "/portaladmin/security/sslCertificates/update").request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token(@portal_url + '/sharing/generateToken')

      request.set_form_data(
        'webServerCertificateAlias' => cert_alias,
        'token' => token,
        'f' => 'json')

      response = send_request(request)

      validate_response(response)
    end

    def content_dir
      token = generate_token(@portal_url + '/sharing/generateToken')

      content_directory_uri = URI.parse(@portal_url + '/portaladmin/system/directories/content')

      content_directory_uri.query = URI.encode_www_form('token' => token,
                                                        'f' => 'json')

      request = Net::HTTP::Get.new(content_directory_uri.request_uri)
      request.add_field('Referer', 'referer')

      response = send_request(request)

      validate_response(response)

      JSON.parse(response.body)['physicalPath']
    end

    def set_content_dir(content_dir)
      token = generate_token(@portal_url + '/sharing/generateToken')

      request = Net::HTTP::Post.new(URI.parse(
        @portal_url + '/portaladmin/system/directories/content/edit').request_uri)
      request.add_field('Referer', 'referer')

      request.set_form_data('token' => token,
                            'physicalPath' => content_dir,
                            'description' => 'The content directory.',
                            'f' => 'json')

      response = send_request(request)

      validate_response(response)
    end

    def servers
      uri = URI.parse(@portal_url + '/sharing/portals/self/servers/')

      token = generate_token(@portal_url + '/sharing/generateToken')

      uri.query = URI.encode_www_form('token' => token,
                                      'f' => 'json')

      request = Net::HTTP::Get.new(uri.request_uri)
      request.add_field('Referer', 'referer')

      response = send_request(request)

      validate_response(response)

      JSON.parse(response.body)['servers']
    end

    def register_server(server_name, server_url, admin_url, is_hosted, server_type)
      token = generate_token(@portal_url + '/sharing/generateToken')

      request = Net::HTTP::Post.new(URI.parse(
        @portal_url + '/sharing/portals/self/servers/register').request_uri)
      request.add_field('Referer', 'referer')

      request.set_form_data('token' => token,
                            'name' => server_name,
                            'url' => server_url,
                            'adminUrl' => admin_url,
                            'isHosted' => is_hosted,
                            'serverType' => server_type,
                            'f' => 'json')

      response = send_request(request)

      validate_response(response)

      JSON.parse(response.body)
    end

    def federate_server(server_url, admin_url, username, password)
      token = generate_token(@portal_url + '/sharing/generateToken')

      request = Net::HTTP::Post.new(URI.parse(
        @portal_url + '/portaladmin/federation/servers/federate').request_uri)
      request.add_field('Referer', 'referer')

      request.set_form_data('token' => token,
                            'url' => server_url,
                            'adminUrl' => admin_url,
                            'username' => username,
                            'password' => password,
                            'f' => 'json')

      response = send_request(request)

      validate_response(response)

      JSON.parse(response.body)['serverId']
    end

    def update_server(server_id, server_role, function)
      token = generate_token(@portal_url + '/sharing/generateToken')

      request = Net::HTTP::Post.new(URI.parse(@portal_url +
        "/portaladmin/federation/servers/#{server_id}/update").request_uri)
      request.add_field('Referer', 'referer')

      request.set_form_data('token' => token,
                            'serverRole' => server_role,
                            'serverFunction' => function,
                            'f' => 'json')

      response = send_request(request)

      validate_response(response)

      JSON.parse(response.body)['serverId']
    end

    def update_system_properties(system_properties)
      return if system_properties.empty?

      request = Net::HTTP::Post.new(URI.parse(
        @portal_url + '/portaladmin/system/properties/update').request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token(@portal_url + '/sharing/generateToken')

      request.set_form_data('token' => token,
                            'properties' => system_properties.to_json,
                            'f' => 'json')

      response = send_request(request)

      validate_response(response)
    end

    def webadaptors_shared_key
      uri = URI.parse(@portal_url + '/portaladmin/system/webadaptors/config/')

      token = generate_token(@portal_url + '/sharing/generateToken')

      uri.query = URI.encode_www_form('token' => token,
                                      'f' => 'json')

      request = Net::HTTP::Get.new(uri.request_uri)
      request.add_field('Referer', 'referer')

      response = send_request(request)

      validate_response(response)

      JSON.parse(response.body)['sharedKey']
    end

    def update_webadaptors_shared_key(shared_key)
      request = Net::HTTP::Post.new(URI.parse(
        @portal_url + '/portaladmin/system/webadaptors/config/update').request_uri)
      request.add_field('Referer', 'referer')

      token = generate_token(@portal_url + '/sharing/generateToken')

      web_adaptors_config = { 'sharedKey' => shared_key }

      request.set_form_data('webAdaptorsConfig' => web_adaptors_config.to_json,
                            'token' => token,
                            'f' => 'json')

      response = send_request(request)

      validate_response(response)
    end

    def generate_token(generate_token_url)
      request = Net::HTTP::Post.new(URI.parse(generate_token_url).request_uri)

      request.set_form_data('username' => @admin_username,
                            'password' => @admin_password,
                            'client' => 'referer',
                            'referer' => 'referer',
                            'expiration' => '600',
                            'f' => 'json')

      response = send_request(request)

      validate_response(response)

      JSON.parse(response.body)['token']
    end

    def edit_log_settings(log_level, log_dir, max_log_file_age)
      request = Net::HTTP::Post.new(URI.parse(
        @portal_url + '/portaladmin/logs/settings/edit').request_uri)

      request.add_field('Referer', 'referer')

      token = generate_token(@portal_url + '/sharing/generateToken')

      request.set_form_data('logLevel' => log_level,
                            'logDir' => log_dir,
                            'maxLogFileAge' => max_log_file_age,
                            'token' => token,
                            'f' => 'json')

      response = send_request(request)

      validate_response(response)
    end

    def add_root_cert(cert_location, cert_alias, norestart)
      begin
        require 'net/http/post/multipart'
      rescue LoadError
        Chef::Log.error("Missing gem 'multipart-post'. Use the 'system' recipe to install it first.")
      end

      url = URI.parse(@portal_url + 
        '/portaladmin/security/sslCertificates/importRootOrIntermediate')
      token = generate_token(@portal_url + '/sharing/generateToken')

      request = Net::HTTP::Post::Multipart.new(url.path,
        'file' => UploadIO.new(cert_location, 'application/x-x509-ca-cert'),
        'alias' => cert_alias,
        'norestart' => norestart,
        'token' => token,
        'f' => 'json')

      request.add_field('Referer', 'referer')

      response = send_request(request)

      if response.code.to_i == 200
        error_info = JSON.parse(response.body)
        raise error_info['error']['message'] unless error_info['error'].nil?
      end
    end

    private

    def send_request(request)
      uri = URI.parse(@portal_url)

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
          request = Net::HTTP::Post.new(URI.parse(response.header['location']).request_uri)
          request.body = (body)
        else
          request = Net::HTTP::Get.new(URI.parse(response.header['location']).request_uri)
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
