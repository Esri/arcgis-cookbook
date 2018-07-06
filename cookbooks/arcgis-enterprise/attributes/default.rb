#
# Cookbook Name:: arcgis-enterprise
# Attributes:: default
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

default['arcgis']['run_as_user'] = 'arcgis'
if ENV['ARCGIS_RUN_AS_PASSWORD'].nil?
  default['arcgis']['run_as_password'] = 'Pa$$w0rdPa$$w0rd'
else
  default['arcgis']['run_as_password'] = ENV['ARCGIS_RUN_AS_PASSWORD']
end

default['arcgis']['version'] = '10.6.1'

default['arcgis']['cache_authorization_files'] = false
default['arcgis']['configure_windows_firewall'] = false

case node['platform']
when 'windows'
  default['arcgis']['python']['install_dir'] = 'C:\\Python27'
  default['arcgis']['repository']['setups'] = ::File.join(ENV['USERPROFILE'], 'Documents')
  repository_archives = ::File.join(ENV['USERPROFILE'], 'Software\\Esri')
  default['arcgis']['post_install_script'] = 'C:\\imageryscripts\\deploy.bat'
else # node['platform'] == 'linux'
  if node['current_user'] != node['arcgis']['run_as_user']
    has_sudo_privilege = `id -u`
    if has_sudo_privilege.to_i == 0
      default['arcgis']['run_as_superuser'] = true
    else
      Chef::Application.fatal!("Chef is running as user \"#{node['current_user']}\" without super-user privileges, but run_as_user is set to \"#{node['arcgis']['run_as_user']}\". Please use sudo, or run as \"#{node['arcgis']['run_as_user']}\".")
    end
  end
  default['arcgis']['python']['install_dir'] = '' # Not needed on Linux.
  default['arcgis']['web_server']['webapp_dir'] = '' # Depends on type of web server
  default['arcgis']['repository']['setups'] = '/opt/arcgis'
  repository_archives = '/tmp/software/esri'
  default['arcgis']['post_install_script'] = '/arcgis/imageryscripts/deploy.sh'
end

default['arcgis']['repository']['archives'] = repository_archives

if node['arcgis']['repository']['archives'].nil?
  default['arcgis']['repository']['patches'] = ::File.join(repository_archives, 'patches')
else
  default['arcgis']['repository']['patches'] = ::File.join(node['arcgis']['repository']['archives'], 'patches')
end

if node['arcgis']['repository']['patches'].nil?
  default['arcgis']['patches']['local_patch_folder'] = ::File.join(repository_archives, 'patches')
else
  default['arcgis']['patches']['local_patch_folder'] = node['arcgis']['repository']['patches']
end

default['arcgis']['python']['runtime_environment'] = ''
