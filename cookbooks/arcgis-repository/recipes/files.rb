#
# Cookbook:: arcgis-repository
# Recipe:: files
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

# Create archives directory
directory node['arcgis']['repository']['local_archives'] do
  mode '0755' if node['platform'] != 'windows'
  recursive true
  action :create
end

arcgis_repository_files 'Download files from remote repository' do
  server node['arcgis']['repository']['server']
  files node['arcgis']['repository']['files']
  local_archives node['arcgis']['repository']['local_archives']
  retries 5
  retry_delay 10
  sensitive true
  action :download
end
