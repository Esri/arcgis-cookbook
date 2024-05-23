#
# Cookbook Name:: arcgis-workflow-manager
# Resource:: server
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

unified_mode true

actions :system, :unpack, :install, :uninstall, :authorize, 
        :configure_autostart, :stop, :start, :configure

attribute :install_dir, :kind_of => String
attribute :setup_archive, :kind_of => String
attribute :setups_repo, :kind_of => String
attribute :setup, :kind_of => String
attribute :run_as_user, :kind_of => String
attribute :run_as_password, :kind_of => String, :sensitive => true
attribute :run_as_msa, :kind_of => [TrueClass, FalseClass], :default => false
attribute :authorization_file, :kind_of => String
attribute :authorization_file_version, :kind_of => String
attribute :product_code, :kind_of => String
attribute :ports, :kind_of => String
attribute :enabled_modules, :kind_of => String
attribute :disabled_modules, :kind_of => String

def initialize(*args)
  super
  @action = :install
end

use_inline_resources if defined?(use_inline_resources)

require 'fileutils'

action :system do
  ports = @new_resource.ports
  case node['platform']
  when 'windows'
    # Configure Windows firewall
    windows_firewall_rule 'ArcGIS Workflow Manager Server' do
      description 'Allows connections through ports used by ArcGIS Workflow Manager Server'
      local_port ports
      protocol 'TCP'
      firewall_action :allow
      only_if { node['arcgis']['configure_windows_firewall'] }
    end
  end
  new_resource.updated_by_last_action(true)
end

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
end

action :install do
  unless ::File.exist?(@new_resource.setup)
    raise "File '#{@new_resource.setup}' not found."
  end

  if node['platform'] == 'windows'
    cmd = @new_resource.setup

    password = if @new_resource.run_as_msa
                 'MSA=\"True\"'
               else
                 "PASSWORD=\"#{@new_resource.run_as_password}\""
               end

    args = "/qn ACCEPTEULA=Yes #{password}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    Utils.sensitive_command_error(cmd, [ @new_resource.run_as_password ])
  else
    cmd = @new_resource.setup
    args = "-m silent -l yes"
    run_as_user = @new_resource.run_as_user

    if node['arcgis']['run_as_superuser']
      cmd = Mixlib::ShellOut.new("su - #{run_as_user} -c \"#{cmd} #{args}\"", { :timeout => 3600 })
    else
      cmd = Mixlib::ShellOut.new("#{cmd} #{args}", { :user => run_as_user, :timeout => 3600 })
    end

    cmd.run_command
    cmd.error!
  end
end

# Set play.modules.disabled and play.modules.enabled properties in WorkflowManager.conf 
action :configure do
  if node['platform'] == 'windows'
    workflowmanager_conf = ::File.join(ENV['ProgramData'], 'ESRI\\workflowmanager\\WorkflowManager.conf')
  else
    run_as_user = @new_resource.run_as_user
    hostname = `uname -n`.strip
    workflowmanager_conf = "/home/#{run_as_user}/.esri/WorkflowManager/#{hostname}/workflowManager.conf"
  end

  workflowmanager_conf_tmp = workflowmanager_conf + '.tmp'

  open(workflowmanager_conf, 'r') do |src|
    open(workflowmanager_conf_tmp, 'w') do |dst|
      src.each_line do |line|
        unless ((line.start_with?('play.modules.disabled') && !@new_resource.disabled_modules.nil?) || 
                (line.start_with?('play.modules.enabled') && !@new_resource.enabled_modules.nil?)) 
          dst.write(line)
          unless line.end_with?("\n")
            dst.write("\n")
          end
        end
      end
      
      unless @new_resource.disabled_modules.nil?
        dst.write("play.modules.disabled += \"#{@new_resource.disabled_modules}\"\n")
      end

      unless @new_resource.enabled_modules.nil?
        dst.write("play.modules.enabled += \"#{@new_resource.enabled_modules}\"\n")
      end
    end
  end
  
  FileUtils.mv(workflowmanager_conf_tmp, workflowmanager_conf)
  FileUtils.chown(@new_resource.run_as_user, nil, workflowmanager_conf)
end

action :uninstall do
  if node['platform'] == 'windows'
    cmd = 'msiexec'
    args = "/qn /x #{@new_resource.product_code}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['server']['install_subdir'])
    cmd = ::File.join(install_subdir, 'uninstall_WorkflowManager.sh')

    cmd = Mixlib::ShellOut.new("su - #{@new_resource.run_as_user} -c \"#{cmd}\"",
                               { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  end
end

action :authorize do
  if !@new_resource.authorization_file.nil? && !@new_resource.authorization_file.empty?
    unless ::File.exists?(@new_resource.authorization_file)
      raise "File '#{@new_resource.authorization_file}' not found."
    end

    cmd = node['arcgis']['server']['authorization_tool']

    if node['platform'] == 'windows'
      args = "/VER #{@new_resource.authorization_file_version} /LIF \"#{@new_resource.authorization_file}\" /S"

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 600 })
      cmd.run_command
      cmd.error!
    else
      args = "-f \"#{@new_resource.authorization_file}\""

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
            { :timeout => 600, :user => node['arcgis']['run_as_user'] })
      cmd.run_command
      cmd.error!
    end

    new_resource.updated_by_last_action(true)
  end
end

action :configure_autostart do
  if node['platform'] == 'windows'
    service 'WorkflowManager' do
      action :enable
    end
  else
    Chef::Log.info('Configure ArcGIS Workflow Manager Server to be started with the operating system.')
    agsuser = node['arcgis']['run_as_user']
    agshome = ::File.join(@new_resource.install_dir,
                          node['arcgis']['server']['install_subdir'])

    if node['init_package'] == 'systemd'
      workflowmanager_path = '/etc/systemd/system/workflowmanager.service'
      service_file = 'workflowmanager.service.erb'
      template_variables = { :agshome => agshome, :agsuser => agsuser }
    else
      raise 'System not supported.'
    end

    template workflowmanager_path do
      source service_file
      cookbook 'arcgis-workflow-manager'
      variables template_variables
      owner 'root'
      group 'root'
      mode '0755'
      notifies :run, 'execute[Load systemd unit file]', :immediately
    end

    execute 'Load systemd unit file' do
      command 'systemctl daemon-reload'
      action :nothing
      only_if { node['init_package'] == 'systemd' }
      notifies :restart, 'service[workflowmanager]', :immediately
    end

    service 'workflowmanager' do
      supports :status => true, :restart => true, :reload => true
      action :enable
      retries 5
      retry_delay 60
    end
  end
end

action :stop do
  if node['platform'] == 'windows'
    service "WorkflowManager" do
      supports :status => true, :restart => true, :reload => true
      action :stop
    end
  else
    service "workflowmanager" do
      supports :status => true, :restart => true, :reload => true
      action :stop
    end
  end
end

action :start do
  if node['platform'] == 'windows'
    service "WorkflowManager" do
      supports :status => true, :restart => true, :reload => true
      timeout 180
      action [:enable, :start]
    end
  else
    service "workflowmanager" do
      supports :status => true, :restart => true, :reload => true
      action [:enable, :start]
    end
  end
end
