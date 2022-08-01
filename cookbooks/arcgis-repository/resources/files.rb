#
# Cookbook:: arcgis-repository
# Resource:: files
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
#

actions :download

attribute :server, kind_of: Hash, default: {}
attribute :files, kind_of: Hash, default: {}
attribute :local_archives, kind_of: String

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

  @new_resource.files.each do |file, props|
    Chef::Log.debug("Downloading #{file}.")

    if props['url'].nil?
      url = downloads_service.generate_url(file, props['subfolder'], token)
    else
      url = props['url']
    end

    path = ::File.join(@new_resource.local_archives, file)

    unless ::File.exist?(path)
      Downloader.download(url, path)
    end

    # Download the remote file
    # remote_file file do
    #   path path
    #   source url
    #   mode '0755' if node['platform'] != 'windows'
    #   backup false
    #   # checksum props['checksum']
    #   not_if { ::File.exist?(path) }
    #   action :create
    # end
  end
end
