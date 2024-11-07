#
# Cookbook Name:: arcgis-enterprise
# Attributes:: default
#
# Copyright 2023-2024 Esri
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

include_attribute 'arcgis-repository'

default['arcgis']['run_as_user'] = 'arcgis'
default['arcgis']['run_as_uid'] = 1100
default['arcgis']['run_as_gid'] = 1100

if ENV['ARCGIS_RUN_AS_PASSWORD'].nil?
  default['arcgis']['run_as_password'] = nil
else
  default['arcgis']['run_as_password'] = ENV['ARCGIS_RUN_AS_PASSWORD']
end

default['arcgis']['run_as_msa'] = false
default['arcgis']['run_as_user_auth_keys'] = nil

default['arcgis']['version'] = '11.4'

default['arcgis']['cache_authorization_files'] = false
default['arcgis']['configure_windows_firewall'] = false

default['arcgis']['cloud']['provider'] = ''

if node['cloud'] || ENV['arcgis_cloud_platform'] == 'aws'
  default['arcgis']['configure_cloud_settings'] = true

  if ENV['arcgis_cloud_platform'] == 'aws'
    default['arcgis']['cloud']['provider'] = 'ec2'
  elsif !node['cloud']['provider'].nil?
    default['arcgis']['cloud']['provider'] = node['cloud']['provider']
  end
else
  default['arcgis']['configure_cloud_settings'] = false
end

case node['platform']
when 'windows'
  default['arcgis']['python']['install_dir'] = 'C:\\Python27'
  default['arcgis']['post_install_script'] = 'C:\\imageryscripts\\deploy.bat'
else # node['platform'] == 'linux'
  default['arcgis']['configure_autofs'] = true

  default['arcgis']['packages'] =
    case node['platform']
    when 'redhat', 'centos', 'amazon', 'oracle', 'rocky'
      node['arcgis']['configure_autofs'] ?
        ['gettext', 'nfs-utils', 'autofs'] :
        ['gettext']
    when 'almalinux'
      node['arcgis']['configure_autofs'] ?
        ['gettext', 'glibc-langpack-en', 'nfs-utils', 'autofs'] :
        ['gettext', 'glibc-langpack-en']
    when 'suse'
      node['arcgis']['configure_autofs'] ?
        ['gettext-runtime', 'autofs'] :
        ['gettext-runtime']
    else
      node['arcgis']['configure_autofs'] ? 
        ['gettext-base', 'libxrender1', 'libxtst6', 'libxi6', 'autofs'] :
        ['gettext-base', 'libxrender1', 'libxtst6', 'libxi6']
    end
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
  default['arcgis']['post_install_script'] = '/arcgis/imageryscripts/deploy.sh'
end

default['arcgis']['python']['runtime_environment'] = ''
default['arcgis']['clean_install_dirs'] = false # Delete install dirs in 'clean' recipe
