#
# Cookbook:: arcgis-repository
# Resource:: files
#
# Copyright 2023 Esri
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
#

unified_mode true

actions :download

attribute :server, kind_of: Hash, default: {}
attribute :files, kind_of: Hash, default: {}
attribute :local_archives, kind_of: String

require "digest"

def initialize(*args)
  super
  @action = :download
end

use_inline_resources if defined?(use_inline_resources)

action :download do
  token_service = ArcGIS::TokenServiceClient.new(
    @new_resource.server['token_service_url'])

  downloads_service = ArcGIS::DownloadsAPIClient.new(
    @new_resource.server['url'])

  unless @new_resource.server['username'].nil? || 
         @new_resource.server['password'].nil?  
    token = token_service.generate_token(
      @new_resource.server['username'],
      @new_resource.server['password']
    )
  end

  Chef::Log.info("Downloading files from #{@new_resource.server['url']}...")

  @new_resource.files.each do |file, props|
    Chef::Log.debug("Downloading '#{file}'.")

    if props['url'].nil?
      url = downloads_service.generate_url(file, props['subfolder'], token)
    else
      url = props['url']
    end

    path = ::File.join(@new_resource.local_archives, file)

    unless ::File.exist?(path)
      Downloader.download(url, path)
    end

    size = ::File.size(path)
    sha256 = Digest::SHA256.file(path).hexdigest    

    Chef::Log.info("'#{file}' downloaded. Size = #{size}, SHA256 checksum = #{sha256}")

    if props['sha256'] != nil && props['sha256'].casecmp(sha256) != 0
      ::File.delete(path)
      raise "SHA256 checksum validation failed for file '#{file}'."
    end

    if props['md5'] != nil
      md5 = Digest::MD5.file(path).hexdigest
      if props['md5'].casecmp(md5) != 0
        ::File.delete(path)
        raise "MD5 checksum validation failed for file '#{file}'."
      end
    end
  end
end
