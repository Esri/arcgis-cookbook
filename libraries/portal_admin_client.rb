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

require "net/http"
require "uri"
require "json"

module ArcGIS
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
    
    def wait_until_available()
      Utils.wait_until_url_available(@portal_url + "/portaladmin")
    end

    def site_exist?()
      uri = URI.parse(@portal_url + "/portaladmin/?f=json")

      request = Net::HTTP::Get.new(uri.request_uri)
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 3600
  
      if uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      response = http.request(request)
      
      if response.code.to_i == 200
        error_info = JSON.parse(response.body)
        if error_info['error'] != nil && error_info['error']['code'].to_i == 499
          return true
        end
      end
      
      return false
    end

    def create_site(admin_email, admin_full_name, admin_description, security_question, security_question_answer)
      create_site_uri = URI.parse(@portal_url + '/portaladmin/createNewSite')
  
      request = Net::HTTP::Post.new(create_site_uri.request_uri)
  
      request.set_form_data({
        "username" => @admin_username,
        "password" => @admin_password,
        "email" => admin_email,
        "fullname" => admin_full_name,
        "description" => admin_description,
        "securityQuestion" => security_question,
        "securityQuestionAns" => security_question_answer,
        "f" => "json"})
  
      response = send_request(request)
  
      validate_response(response)
    end
    
    def get_content_dir()
      token = generate_token(@portal_url + "/sharing/generateToken")
        
      content_directory_uri = URI.parse(@portal_url + '/portaladmin/system/directories/content')
    
      content_directory_uri.query = URI.encode_www_form({
        "token" => token,
        "f" => "json"})
    
      request = Net::HTTP::Get.new(content_directory_uri.request_uri)
      request.add_field("Referer", "referer")
    
      response = send_request(request)
    
      validate_response(response)
        
      json_response = JSON.parse(response.body)
    
      return json_response['physicalPath']
    end
    
    def set_content_dir(content_dir)
      token = generate_token(@portal_url + "/sharing/generateToken")
      
      request = Net::HTTP::Post.new(URI.parse(@portal_url + '/portaladmin/system/directories/content/edit').request_uri)
      request.add_field("Referer", "referer")
    
      request.set_form_data({
        "token" => token,
        "physicalPath" => content_dir,
        "description" => "The content directory.",  
        "f" => "json"})
    
      response = send_request(request)
    
      validate_response(response)
    end 
       
    def get_servers()
      uri = URI.parse(@portal_url + "/sharing/portals/self/servers/")

      token = generate_token(@portal_url + "/sharing/generateToken")
            
      uri.query = URI.encode_www_form({
        "token" => token,
        "f" => "json"})

      request = Net::HTTP::Get.new(uri.request_uri)
      request.add_field("Referer", "referer")

      response = send_request(request)

      validate_response(response)
      
      return JSON.parse(response.body)['servers']
    end
    
    def register_server(server_name, server_url, admin_url, is_hosted, server_type)
      token = generate_token(@portal_url + "/sharing/generateToken")
      
      request = Net::HTTP::Post.new(URI.parse(@portal_url + "/sharing/portals/self/servers/register").request_uri)
      request.add_field("Referer", "referer")
    
      request.set_form_data({
        "token" => token,
        "name" => server_name,
        "url" => server_url,
        "adminUrl" => admin_url,
        "isHosted" => is_hosted,
        "serverType" => server_type,
        "f" => "json"})
    
      response = send_request(request)

      validate_response(response)
      
      return JSON.parse(response.body)
    end
    
    def update_system_properties(domain)
      request = Net::HTTP::Post.new(URI.parse(@portal_url + "/portaladmin/system/properties/update").request_uri)
      request.add_field("Referer", "referer")
      
      token = generate_token(@portal_url + "/sharing/generateToken")
    
      system_properties = {
        "localHttpPort" => "80",
        "localHttpsPort" => "443",
        "portalLocalHostname" => domain,
        "privatePortalURL" => @portal_url
      }
      
      request.set_form_data({
        "token" => token,
        "properties" => system_properties.to_json,
        "f" => "json"})
    
      response = send_request(request)

      validate_response(response)
    end
    
    def get_webadaptors_shared_key
      uri = URI.parse(@portal_url + "/portaladmin/system/webadaptors/config/")

      token = generate_token(@portal_url + "/sharing/generateToken")
            
      uri.query = URI.encode_www_form({
        "token" => token,
        "f" => "json"})

      request = Net::HTTP::Get.new(uri.request_uri)
      request.add_field("Referer", "referer")

      response = send_request(request)

      validate_response(response)
      
      return JSON.parse(response.body)['sharedKey']
    end
    
    def update_webadaptors_shared_key(shared_key)
      request = Net::HTTP::Post.new(URI.parse(@portal_url + "/portaladmin/system/webadaptors/config/update").request_uri)
      request.add_field("Referer", "referer")
      
      token = generate_token(@portal_url + "/sharing/generateToken")
    
      web_adaptors_config = {
        "sharedKey" => shared_key
      }
      
      request.set_form_data({
        "webAdaptorsConfig" => web_adaptors_config.to_json,
        "token" => token,
        "f" => "json"})
    
      response = send_request(request)

      validate_response(response)
    end
    
    def generate_token(generate_token_url)
      request = Net::HTTP::Post.new(URI.parse(generate_token_url).request_uri)
  
      request.set_form_data({
          "username" => @admin_username,
          "password" => @admin_password,
          "client" => "referer",
          "referer" => "referer",
          "expiration" => "600",
          "f" => "json"})
  
      response = send_request(request)
      
      validate_response(response)
      
      token = JSON.parse(response.body)
  
      return token['token']
    end

    private
     
    def send_request(request) 
      uri = URI.parse(@portal_url)
    
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 3600
  
      if uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      Chef::Log.debug("Request: #{request.method} #{uri.scheme}://#{uri.host}:#{uri.port}#{request.path}")
      
      if !request.body.nil?
        Chef::Log.debug(request.body)
      end
      
      response = http.request(request)
      
      if response.code.to_i == 301
        Chef::Log.debug("Moved to: #{response.header['location']}")
        
        uri = URI.parse(response.header['location']);

        http = Net::HTTP.new(uri.host, uri.port)
        http.read_timeout = 3600
    
        if uri.scheme == "https"
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        if request.method == "POST"
          body = request.body 
          request = Net::HTTP::Post.new(URI.parse(response.header['location']).request_uri)
          request.body=(body)
        else
          request = Net::HTTP::Get.new(URI.parse(response.header['location']).request_uri)
        end

        request.add_field("Referer", "referer")
                
        response = http.request(request)
      end
      
      Chef::Log.debug("Response: #{response.code} #{response.body}")

      return response
    end
    
    def validate_response(response)
      if response.code.to_i >= 300 
        raise response.message
      elsif response.code.to_i == 200
        error_info = JSON.parse(response.body)
        if error_info['error'] != nil
          raise error_info['error']['message']
        end
      end
    end    
  end
end
