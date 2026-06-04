# Cookbook Name:: arcgis-notebooks
# Recipe:: docker
#
# Copyright 2022-2026 Esri
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

arcgis_notebooks_docker "Install Docker CE" do
  version node['arcgis']['notebook_server']['docker_version']
  docker_repository_url node['arcgis']['notebook_server']['docker_repository_url']
  only_if { node['arcgis']['notebook_server']['install_docker'] }
  action :install
end

# See: https://docs.docker.com/reference/cli/dockerd/#daemon-configuration-file
file '/etc/docker/daemon.json' do
  content node['arcgis']['notebook_server']['docker_daemon_json']
  mode '0644'
  not_if { node['arcgis']['notebook_server']['docker_daemon_json'].nil? }
end
