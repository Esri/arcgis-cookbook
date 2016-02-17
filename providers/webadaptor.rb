#
# Cookbook Name:: arcgis
# Provider:: webadaptor
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
#

require 'fileutils'
require 'net/http'
require 'uri'
require 'json'

action :system do
  if node['platform'] == 'windows'
    @run_context.include_recipe 'arcgis::iis'

    new_resource.updated_by_last_action(true)
    # else
    # TODO: Ensure Web Adaptor system requirements on Linux
  end
end

action :install do
  if node['platform'] == 'windows'
    cmd = @new_resource.setup
    args = "/qb VDIRNAME=#{@new_resource.instance_name}"
    web_app_path = node['arcgis']['iis']['wwwroot'] + @new_resource.instance_name

    execute 'Run ArcGIS Web Adaptor Setup' do
      command "\"#{cmd}\" #{args}"
      only_if { !::File.exist?(web_app_path) }
    end
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['web_adaptor']['install_subdir'])
    src_path = ::File.join(install_subdir, 'java/arcgis.war')
    dst_path = ::File.join(node['tomcat']['webapp_dir'],
                           @new_resource.instance_name + '.war')
    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\""

    subdir = @new_resource.install_dir
    node['arcgis']['web_adaptor']['install_subdir'].split('/').each do |path|
      subdir = ::File.join(subdir, path)
      directory subdir do
        owner node['arcgis']['run_as_user']
        group 'root'
        mode '0755'
        action :create
      end
    end

    execute 'Run ArcGIS Web Adaptor Setup' do
      command "\"#{cmd}\" #{args}"
      user node['arcgis']['run_as_user']
      only_if { !::File.exist?(src_path) }
    end

    remote_file dst_path do
      source 'file://' + src_path
      mode '0755'
      only_if { !::File.exist?(dst_path) }
    end

    service node['tomcat']['base_instance'] do
      action :restart
    end
  end

  new_resource.updated_by_last_action(true)
end

action :uninstall do
  if node['platform'] == 'windows'
    cmd = 'msiexec'
    product_code = @new_resource.product_code
    args = "/qb /x #{product_code}"

    execute 'Uninstall ArcGIS Web Adaptor' do
      command "\"#{cmd}\" #{args}"
      only_if { Utils.product_installed?(product_code) }
    end
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['web_adaptor']['install_subdir'])
    cmd = ::File.join(install_subdir, 'java/uninstall_WebAdaptor')
    args = '-s'

    execute 'Uninstall ArcGIS Web Adaptor' do
      command "su - #{node['arcgis']['run_as_user']} -c \"#{cmd} #{args}\""
      only_if { ::File.exist?(cmd) }
    end
  end

  new_resource.updated_by_last_action(true)
end

action :configure_with_server do
  wa_url = @new_resource.server_url + '/webadaptor'
  uri = URI.parse(@new_resource.server_local_url)
  server_url = uri.scheme + '://' + uri.host + ':' + uri.port.to_s

  ruby_block 'Wait for Server and WA' do
    block do
      Utils.wait_until_url_available(wa_url)
      Utils.wait_until_url_available(server_url)
    end
    action :run
  end

  if node['platform'] == 'windows'
    cmd = ::File.join(ENV['CommonProgramFiles(x86)'],
                      '\\ArcGIS\\WebAdaptor\\IIS\\Tools\\ConfigureWebAdaptor.exe')
    args = "/m server /w \"#{wa_url}\" /g \"#{server_url}\" /u \"#{@new_resource.username}\" /p \"#{@new_resource.password}\" /a #{@new_resource.admin_access}"

    execute 'Configure Web Adaptor with Server' do
      command "\"#{cmd}\" #{args}"
    end
  else
    cmd = 'java'
    wareg_jar_path = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['web_adaptor']['install_subdir'],
                                 'java/tools/arcgis-wareg.jar')
    args = "-jar \"#{wareg_jar_path}\" -m server -w '#{wa_url}' -g '#{server_url}' -u '#{@new_resource.username}' -p '#{@new_resource.password}' -a #{@new_resource.admin_access}"

    execute 'Configure Web Adaptor with Server' do
      command "\"#{cmd}\" #{args}"
    end
  end

  new_resource.updated_by_last_action(true)
end

action :configure_with_portal do
  wa_url = @new_resource.portal_url + '/webadaptor'
  uri = URI.parse(@new_resource.portal_local_url)
  portal_local_url = uri.scheme + '://' + uri.host + ':' + uri.port.to_s

  if node['platform'] == 'windows'
    service 'Portal for ArcGIS' do
      action [:restart]
    end
  end

  ruby_block 'Wait until Portal and Web Adaptor are available' do
    block do
      Utils.wait_until_url_available(portal_local_url)
      Utils.wait_until_url_available(wa_url)
    end
    action :run
  end

  if node['platform'] == 'windows'
    cmd = ::File.join(ENV['CommonProgramFiles(x86)'],
                      '\\ArcGIS\\WebAdaptor\\IIS\\Tools\\ConfigureWebAdaptor.exe')
    args = "/m portal /w \"#{wa_url}\" /g \"#{portal_local_url}\" /u \"#{@new_resource.username}\" /p \"#{@new_resource.password}\""

    execute 'Configure Web Adaptor with Portal' do
      command "\"#{cmd}\" #{args}"
    end
  else
    cmd = 'java'
    wareg_jar_path = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['web_adaptor']['install_subdir'],
                                 'java/tools/arcgis-wareg.jar')
    args = "-jar \"#{wareg_jar_path}\" -m portal -w '#{wa_url}' -g '#{portal_local_url}' -u '#{@new_resource.username}' -p '#{@new_resource.password}'"

    execute 'Configure Web Adaptor with Portal' do
      command "\"#{cmd}\" #{args}"
      retries 5
      retry_delay 60
    end
  end

  ruby_block 'Wait until portal is available' do
    block do
      Utils.wait_until_url_available(portal_local_url)
    end
    action :run
  end

  new_resource.updated_by_last_action(true)
end
