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
    # Client class for ArcGIS patches repository.
    #
    class PatchesRepositoryClient
  
      @patches_url = nil
  
      def initialize(patches_url)
        @patches_url = patches_url
      end

      def get_patches(products, versions)
        uri = URI.parse(@patches_url)

        request = Net::HTTP::Get.new(uri.request_uri)
  
        response = send_request(request, @patches_url)
      
        raise "URL #{@patches_url} is not available." if response.code.to_i > 200
  
        all_patches = JSON.parse(response.body)['Product']

        patches = []

        all_patches.each do |version_patches|
          if versions.include?(version_patches['version'])
            version_patches['patches'].each do |patch|
              patch_products = patch['Products']
              if products.empty? || products.any? { |product| patch_products.include?(product) }
                patches.append(patch)
              end
            end
          end
        end

        patches
      end

      # Download patches for the specified platform, products, and versions 
      # from the remote patches repository into folder specified by patches_dir parameter.
      def download_patches(platform, products, versions, patches_dir)
        ::Chef::Log.info("Downloading ArcGIS #{versions.join(',')} patches for #{platform} platform.")
        
        accepted_formats  = (platform == 'windows') ? ['.msp'] : ['.tar', '.gz']

        get_patches(products, versions).each do |patch|
          patch['PatchFiles'].each do |file_url|
            uri = URI.parse(file_url)
            if accepted_formats.include?(File.extname(uri.path))
              local_file_path = ::File.join(patches_dir, ::File.basename(uri.path))

              if !::File.exists?(local_file_path)
                Chef::Log.info("Downloading #{file_url} to #{local_file_path}...")
                begin
                  Downloader.download(file_url, local_file_path)
                rescue Exception => e
                  Chef::Log.marn "Failed to download patch from '#{file_url}'. #{e.message}"
                end                  
              end
            end
          end
        end
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