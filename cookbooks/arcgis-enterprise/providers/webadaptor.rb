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
  unless ::File.exists?(@new_resource.setup)
    raise "File '#{@new_resource.setup}' not found."
  end

  if node['platform'] == 'windows'
    # uninstall older WA versions
    installed_code = Utils.wa_product_code(@new_resource.instance_name,
                                           node['arcgis']['web_adaptor']['product_codes'])
    if !installed_code.nil?
      cmd = Mixlib::ShellOut.new("msiexec /qn /x #{installed_code}", {:timeout => 3600})
      cmd.run_command
      cmd.error!
    end

    cmd = @new_resource.setup
    args = "/qn VDIRNAME=#{@new_resource.instance_name} #{@new_resource.setup_options}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", {:timeout => 3600})
    cmd.run_command
    cmd.error!
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['web_adaptor']['install_subdir'])
    src_path = ::File.join(install_subdir, 'java/arcgis.war')

    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\" #{@new_resource.setup_options}"

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
    args = "/qn /x #{@new_resource.product_code}"

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

    Utils.wait_until_url_available(wa_url)
    Utils.wait_until_url_available(server_url)

    if node['platform'] == 'windows'
      cmd = ::File.join(ENV['CommonProgramFiles(x86)'],
          node['arcgis']['web_adaptor']['config_web_adaptor_exe'])
      args = "/m #{@new_resource.mode} /w \"#{wa_url}\" /g \"#{server_url}\" /u \"#{@new_resource.username}\" /p \"#{@new_resource.password}\" /a #{@new_resource.admin_access}"

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", {:timeout => 600})
      cmd.run_command
      cmd.error!
    else
      cmd = 'java'
      wareg_jar_path = ::File.join(@new_resource.install_dir,
                                    node['arcgis']['web_adaptor']['install_subdir'],
                                    'java/tools/arcgis-wareg.jar')
      args = "-jar \"#{wareg_jar_path}\" -m #{@new_resource.mode} -w '#{wa_url}' -g '#{server_url}' -u '#{@new_resource.username}' -p '#{@new_resource.password}' -a #{@new_resource.admin_access}"

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 600 })
      cmd.run_command
      cmd.error!
    end

    new_resource.updated_by_last_action(true)
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
    healthcheck_url = @new_resource.portal_wa_url + '/portaladmin/healthCheck'

    Utils.wait_until_url_available(portal_url)
    Utils.wait_until_url_available(wa_url)

    if node['platform'] == 'windows'
      cmd = ::File.join(ENV['CommonProgramFiles(x86)'],
                        node['arcgis']['web_adaptor']['config_web_adaptor_exe'])
      args = "/m portal /w \"#{wa_url}\" /g \"#{portal_url}\" /u \"#{@new_resource.username}\" /p \"#{@new_resource.password}\""

      args += ' /r false' unless @new_resource.reindex_portal_content

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 600 })
      cmd.run_command
      if (cmd.error? && cmd.stdout.include?('The underlying connection was closed: An unexpected error occurred on a receive.'))
        # Web Adaptor registration failed because portal content reindexing timed out.
        # Log an error and sleep on it, but assume the Web Adaptor registration was successful.
        Chef::Log.error(cmd.stdout)
        sleep(600.0)
        Utils.wait_until_url_available(wa_url)
      else
        cmd.error!
      end
    else
      cmd = 'java'
      wareg_jar_path = ::File.join(@new_resource.install_dir,
                                    node['arcgis']['web_adaptor']['install_subdir'],
                                    'java/tools/arcgis-wareg.jar')
      args = "-jar \"#{wareg_jar_path}\" -m portal -w '#{wa_url}' -g '#{portal_url}' -u '#{@new_resource.username}' -p '#{@new_resource.password}'"

      args += ' -r false' unless @new_resource.reindex_portal_content

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 600 })
      cmd.run_command
      if (cmd.error? && cmd.stdout.include?('The underlying connection was closed: An unexpected error occurred on a receive.'))
        # Web Adaptor registration failed because portal content reindexing timed out.
        # Log an error and sleep on it, but assume the Web Adaptor registration was successful.
        Chef::Log.error(cmd.stdout)
        sleep(600.0)
        Utils.wait_until_url_available(wa_url)
      else
        cmd.error!
      end
    end

    Utils.wait_until_url_available(healthcheck_url)

    # wait_until_url_available does not wait more than 10 minutes.
    # Portal content reindexing during WA registration may take up to 25 minutes.
    Utils.wait_until_url_available(healthcheck_url)

    unless Utils.url_available?(healthcheck_url)
      raise 'Portal health check URL is not available.'
    end

    new_resource.updated_by_last_action(true)
  rescue Exception => e
    Chef::Log.error "Failed to configure Web Adaptor with Portal for ArcGIS. " + e.message
    raise e
  end
end
