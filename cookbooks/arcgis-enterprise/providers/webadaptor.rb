#
# Cookbook Name:: arcgis-enterprise
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

use_inline_resources

action :unpack do
  if node['platform'] == 'windows'
    cmd = @new_resource.setup_archive
    args = "/s /d \"#{@new_resource.setups_repo}\""
    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  else
    cmd = 'tar'
    args = "xzvf \"#{@new_resource.setup_archive}\""
    repo = ::File.join(@new_resource.setups_repo, node['arcgis']['version'])
    FileUtils.mkdir_p(repo) unless ::File.directory?(repo)
    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600, :cwd => repo })
    cmd.run_command
    cmd.error!

    FileUtils.chown_R @new_resource.run_as_user, nil, repo
  end

  new_resource.updated_by_last_action(true)
end

action :install do
  if node['platform'] == 'windows'
    # uninstall older WA versions
    installed_code = Utils.wa_product_code(@new_resource.instance_name,
                                           node['arcgis']['web_adaptor']['product_codes'])
    if !installed_code.nil?
      cmd = Mixlib::ShellOut.new("msiexec /qb /x #{installed_code}", {:timeout => 3600})
      cmd.run_command
      cmd.error!
    end

    cmd = @new_resource.setup
    args = "/qb VDIRNAME=#{@new_resource.instance_name}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", {:timeout => 3600})
    cmd.run_command
    cmd.error!
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['web_adaptor']['install_subdir'])
    src_path = ::File.join(install_subdir, 'java/arcgis.war')

    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\""

    subdir = @new_resource.install_dir
    node['arcgis']['web_adaptor']['install_subdir'].split("/").each do |path|
      subdir = ::File.join(subdir, path)
      FileUtils.mkdir_p(subdir) unless ::File.directory?(subdir)
      FileUtils.chmod 0700, subdir
      FileUtils.chown node['arcgis']['run_as_user'], nil, subdir
    end

    if !::File.exist?(src_path)
      cmd = Mixlib::ShellOut.new("#{cmd} #{args}", {:user => @new_resource.run_as_user, :timeout => 3600})
      cmd.run_command
      cmd.error!
    end
  end

  new_resource.updated_by_last_action(true)
end

action :uninstall do
  if node['platform'] == 'windows'
    cmd = 'msiexec'
    args = "/qb /x #{@new_resource.product_code}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", {:timeout => 3600})
    cmd.run_command
    cmd.error!
  else
    dst_path = ::File.join(node['arcgis']['web_server']['webapp_dir'],
                           @new_resource.instance_name + '.war')

    if ::File.exist?(dst_path)
      FileUtils.rm(dst_path)
    end

    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['web_adaptor']['install_subdir'])
    cmd = ::File.join(install_subdir, 'java/uninstall_WebAdaptor')
    args = '-s'

    if ::File.exist?(cmd)
      cmd = Mixlib::ShellOut.new("#{cmd} #{args}", {:user => node['arcgis']['run_as_user'], :timeout => 3600})
      cmd.run_command
      cmd.error!
    end
  end

  new_resource.updated_by_last_action(true)
end

action :deploy do
  if node['platform'] == 'windows'
    # Do nothing
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['web_adaptor']['install_subdir'])
    src_path = ::File.join(install_subdir, 'java/arcgis.war')
    dst_path = ::File.join(node['arcgis']['web_server']['webapp_dir'],
                           @new_resource.instance_name + '.war')
    begin
      FileUtils.cp(src_path, dst_path)
      FileUtils.chmod(0755, dst_path, :verbose => true)
      sleep(30.0)
    rescue Exception
      Chef::Log.warn("Skipping Deployment: #{$!}")
    end
  end
  new_resource.updated_by_last_action(true)
end

action :configure_with_server do
  begin
    wa_url = @new_resource.server_wa_url + '/webadaptor'
    uri = URI.parse(@new_resource.server_url)
    server_url = uri.scheme + '://' + uri.host + ':' + uri.port.to_s
  
    rest_client = ArcGIS::ServerRestClient.new(@new_resource.server_wa_url,
                                               @new_resource.username,
                                               @new_resource.password)
  
    unless rest_client.available?
      Utils.wait_until_url_available(wa_url)
      Utils.wait_until_url_available(server_url)
  
      if node['platform'] == 'windows'
        cmd = ::File.join(ENV['CommonProgramFiles(x86)'],
                          '\\ArcGIS\\WebAdaptor\\IIS\\Tools\\ConfigureWebAdaptor.exe')
        args = "/m server /w \"#{wa_url}\" /g \"#{server_url}\" /u \"#{@new_resource.username}\" /p \"#{@new_resource.password}\" /a #{@new_resource.admin_access}"
  
        cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", {:timeout => 600})
        cmd.run_command
        cmd.error!
      else
        cmd = 'java'
        wareg_jar_path = ::File.join(@new_resource.install_dir,
                                     node['arcgis']['web_adaptor']['install_subdir'],
                                     'java/tools/arcgis-wareg.jar')
        args = "-jar \"#{wareg_jar_path}\" -m server -w '#{wa_url}' -g '#{server_url}' -u '#{@new_resource.username}' -p '#{@new_resource.password}' -a #{@new_resource.admin_access}"
  
        cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 600 })
        cmd.run_command
        cmd.error!
      end
  
      new_resource.updated_by_last_action(true)
    end
  rescue Exception => e
    Chef::Log.error "Failed to configure Web Adaptor with ArcGIS Server. " + e.message
    raise e
  end
end

action :configure_with_portal do
  begin
    wa_url = @new_resource.portal_wa_url + '/webadaptor'
    uri = URI.parse(@new_resource.portal_url)
    portal_url = uri.scheme + '://' + uri.host + ':' + uri.port.to_s
  
    rest_client = ArcGIS::PortalRestClient.new(@new_resource.portal_wa_url,
                                               @new_resource.username,
                                               @new_resource.password)
  
    unless rest_client.available?
      Utils.wait_until_url_available(portal_url)
      Utils.wait_until_url_available(wa_url)
  
      if node['platform'] == 'windows'
        cmd = ::File.join(ENV['CommonProgramFiles(x86)'],
                          '\\ArcGIS\\WebAdaptor\\IIS\\Tools\\ConfigureWebAdaptor.exe')
        args = "/m portal /w \"#{wa_url}\" /g \"#{portal_url}\" /u \"#{@new_resource.username}\" /p \"#{@new_resource.password}\""
  
        cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 600 })
        cmd.run_command
        cmd.error!
      else
        cmd = 'java'
        wareg_jar_path = ::File.join(@new_resource.install_dir,
                                     node['arcgis']['web_adaptor']['install_subdir'],
                                     'java/tools/arcgis-wareg.jar')
        args = "-jar \"#{wareg_jar_path}\" -m portal -w '#{wa_url}' -g '#{portal_url}' -u '#{@new_resource.username}' -p '#{@new_resource.password}'"
  
        cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 600 })
        cmd.run_command
        cmd.error!
      end
  
      Utils.wait_until_url_available(portal_url)
      sleep(60.0)
      Utils.wait_until_url_available(portal_url)
  
      new_resource.updated_by_last_action(true)
    end
  rescue Exception => e
    Chef::Log.error "Failed to configure Web Adaptor with Portal for ArcGIS. " + e.message
    raise e
  end
end
