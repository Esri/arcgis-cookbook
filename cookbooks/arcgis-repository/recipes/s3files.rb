#
# Cookbook:: arcgis-repository
# Recipe:: s3files
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
#

# Create archives directory
directory node['arcgis']['repository']['local_archives'] do
  mode '0755' if node['platform'] != 'windows'
  recursive true
  action :create
end

node['arcgis']['repository']['files'].each do |filename, props|
  # Download the remote file from S3
  remote_path = props['subfolder'].nil? ? filename : ::File.join(props['subfolder'], filename)
  s3_file filename do
    path ::File.join(node['arcgis']['repository']['local_archives'], filename)
    remote_path remote_path
    bucket node['arcgis']['repository']['server']['s3bucket']
    if !node['arcgis']['repository']['server']['aws_access_key'].empty? 
      aws_access_key_id node['arcgis']['repository']['server']['aws_access_key']
      aws_secret_access_key node['arcgis']['repository']['server']['aws_secret_access_key']
    end
    retries 5
    retry_delay 30
    not_if { ::File.exist?(::File.join(node['arcgis']['repository']['local_archives'], filename)) }
    action :create
  end
end
