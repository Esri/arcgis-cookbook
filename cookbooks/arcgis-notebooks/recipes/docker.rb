# Cookbook Name:: arcgis-notebooks
# Recipe:: docker
#
# Copyright 2019 Esri
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

docker_service 'default' do
  action [:create, :start]
end

# Restart docker service if iptables were rebuilt after docker was started
docker_service 'default' do
  only_if { ::File.exist?("/lib/systemd/system/docker.service") }
  subscribes :restart, 'execute[rebuild-iptables]', :immediately
end
   