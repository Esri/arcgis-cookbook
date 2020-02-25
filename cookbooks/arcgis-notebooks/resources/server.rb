#
# Cookbook Name:: arcgis-notebooks
# Resource:: notebook
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

actions :system, :unpack, :install, :uninstall, :update_account, :stop, :start,
        :configure_autostart, :authorize, :post_install, :create_site, :join_site

attribute :setup_archive, :kind_of => String
attribute :setups_repo, :kind_of => String
attribute :setup, :kind_of => String
attribute :docker_images, :kind_of => String
attribute :install_dir, :kind_of => String
attribute :run_as_user, :kind_of => String
attribute :run_as_password, :kind_of => String
attribute :authorization_file, :kind_of => String
attribute :authorization_file_version, :kind_of => String
attribute :product_code, :kind_of => String
attribute :username, :kind_of => String
attribute :password, :kind_of => String
attribute :server_directories_root, :kind_of => String
attribute :config_store_connection_string, :kind_of => String
attribute :workspace, :kind_of => String
attribute :primary_server_url, :kind_of => String

def initialize(*args)
  super
  @action = :install
end

use_inline_resources if defined?(use_inline_resources)

action :system do
  case node['platform']
  when 'windows'
    # Configure Windows firewall
    windows_firewall_rule 'ArcGIS Notebook Server' do
      description 'Allows connections through all ports used by ArcGIS Notebook Server'
      local_port node['arcgis']['notebook_server']['ports']
      protocol 'TCP'
      firewall_action :allow
      only_if { node['arcgis']['configure_windows_firewall'] }
    end

    # Add run as user to docker user group
    group 'docker-users' do
      members node['arcgis']['run_as_user']
      append true
      action :manage
    end
  else
    # Add run as user to docker user group
    group 'docker' do
      members node['arcgis']['run_as_user']
      append true
      action :manage
    end
  end
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
  if node['platform'] == 'windows'
    cmd = @new_resource.setup
    run_as_password = @new_resource.run_as_password.gsub("&", "^&")
    args = "/qb INSTALLDIR=\"#{@new_resource.install_dir}\" USER_NAME=\"#{@new_resource.run_as_user}\" PASSWORD=\"#{run_as_password}\""

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  else
    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\""
    run_as_user = @new_resource.run_as_user

    cmd = Mixlib::ShellOut.new("su - #{run_as_user} -c \"#{cmd} #{args}\"", { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  end
end

action :uninstall do
  if node['platform'] == 'windows'
    cmd = 'msiexec'
    args = "/qb /x #{@new_resource.product_code}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['notebook_server']['install_subdir'])
    cmd = ::File.join(install_subdir, 'uninstall_ArcGISNotebookServer')
    args = '-s'

    cmd = Mixlib::ShellOut.new("su - #{@new_resource.run_as_user} -c \"#{cmd} #{args}\"",
                               { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  end
end

action :update_account do
  if node['platform'] == 'windows'
    Utils.sc_config('ArcGIS Notebook Server', @new_resource.run_as_user, @new_resource.run_as_password)
  end
end

action :stop do
  if node['platform'] == 'windows'
    service "ArcGIS Notebook Server" do
      supports :status => true, :restart => true, :reload => true
      action :stop
    end
  else
    service "agsnotebook" do
      supports :status => true, :restart => true, :reload => true
      action :stop
    end
  end

  new_resource.updated_by_last_action(true)
end

action :start do
  if node['platform'] == 'windows'
    service "ArcGIS Notebook Server" do
      supports :status => true, :restart => true, :reload => true
      timeout 180
      action [:enable, :start]
    end
  else
    service "agsnotebook" do
      supports :status => true, :restart => true, :reload => true
      action [:enable, :start]
    end
  end
end

action :configure_autostart do
  if node['platform'] == 'windows'
    service "ArcGIS Notebook Server" do
      supports :status => true, :restart => true, :reload => true
      action :enable
    end
  else
    Chef::Log.info('Configure ArcGIS Notebook Server to be started with the operating system.')

    agsuser = node['arcgis']['run_as_user']
    agsnotebookhome = ::File.join(@new_resource.install_dir,
                                  node['arcgis']['notebook_server']['install_subdir'])

    if node['init_package'] == 'init' # SysV
      Chef::Log.warn('SysV not supported.')
    else # node['init_package'] == 'systemd'
      agsnotebook_path = '/etc/systemd/system/agsnotebook.service'
      agsnotebook_service_file = 'agsnotebook.service.erb'
      agsnotebook_template_variables = ({ :agsnotebookhome => agsnotebookhome, :agsuser => agsuser })
    end

    template agsnotebook_path do
      source agsnotebook_service_file
      cookbook 'arcgis-notebooks'
      variables agsnotebook_template_variables
      owner agsuser
      group 'root'
      mode '0755'
      notifies :run, 'execute[Load agsnotebook systemd unit file]', :immediately
    end

    execute 'Load agsnotebook systemd unit file' do
      command 'systemctl daemon-reload'
      action :nothing
      only_if {( node['init_package'] == 'systemd' )}
      notifies :restart, 'service[agsnotebook]', :immediately
    end

    service 'agsnotebook' do
      supports :status => true, :restart => true, :reload => true
      action :enable
    end
  end
end

action :authorize do
  if !@new_resource.authorization_file.nil? && !@new_resource.authorization_file.empty?
    cmd = node['arcgis']['notebook_server']['authorization_tool']

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
  end
end

action :post_install do
  if node['platform'] == 'windows'
    cmd = ::File.join(@new_resource.install_dir, 'tools', 'postInstallUtility', 'PostInstallUtility.bat')
    args = "-l \"#{@new_resource.docker_images}\""

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 1200 })
    cmd.run_command
    cmd.error!
  else
    install_dir = ::File.join(@new_resource.install_dir, node['arcgis']['notebook_server']['install_subdir'])
    cmd = ::File.join(install_dir, 'tools', 'postInstallUtility', 'PostInstallUtility.sh')
    args = "-l #{@new_resource.docker_images}"

    cmd = Mixlib::ShellOut.new("su - #{@new_resource.run_as_user} -c \"#{cmd} #{args}\"",
          { :timeout => 1200 })
    cmd.run_command
    cmd.error!
  end
end

action :create_site do
  if node['platform'] == 'windows'
    cmd = ::File.join(@new_resource.install_dir, 'tools', 'CreateSiteUtility', 'createsite.bat')
    args = "-u \"#{@new_resource.username}\" -p \"#{@new_resource.password}\" " +
           "-d \"#{@new_resource.server_directories_root}\" -c \"#{@new_resource.config_store_connection_string}\" " +
           "-w \"#{@new_resource.workspace}\""

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 1200 })
    cmd.run_command
    cmd.error!
  else
    install_dir = ::File.join(@new_resource.install_dir, node['arcgis']['notebook_server']['install_subdir'])
    cmd = ::File.join(install_dir, 'tools', 'createSiteUtility', 'createsite.sh')
    args = "-u \"#{@new_resource.username}\" -p \"#{@new_resource.password}\" " +
           "-d \"#{@new_resource.server_directories_root}\" -c \"#{@new_resource.config_store_connection_string}\""

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
          { :timeout => 1200, :user => @new_resource.run_as_user })
    cmd.run_command
    cmd.error!
  end
end

action :join_site do
  if node['platform'] == 'windows'
    cmd = ::File.join(@new_resource.install_dir, 'tools', 'JoinSiteUtility', 'joinsite.bat')
    args = "-u \"#{@new_resource.username}\" -p \"#{@new_resource.password}\" " +
           "-s \"#{@new_resource.primary_server_url}\""

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 1200 })
    cmd.run_command
    cmd.error!
  else
    install_dir = ::File.join(@new_resource.install_dir, node['arcgis']['notebook_server']['install_subdir'])
    cmd = ::File.join(install_dir, 'tools', 'joinSiteUtility', 'joinsite.sh')
    args = "-u \"#{@new_resource.username}\" -p \"#{@new_resource.password}\" " +
           "-s \"#{@new_resource.primary_server_url}\""

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
          { :timeout => 1200, :user => @new_resource.run_as_user })
    cmd.run_command
    cmd.error!
  end
end