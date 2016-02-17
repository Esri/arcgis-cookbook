#
# Cookbook Name:: arcgis
# Provider:: datastore
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

action :system do
  arcgis_user @new_resource.recipe_name + ':create-datastore-account'

  case node['platform']
  when 'windows'
  when 'redhat', 'centos'
    ['mesa-libGLU', 'libXdmcp', 'xorg-x11-server-Xvfb'].each do |pckg|
      yum_package @new_resource.recipe_name + ':datastore:' + pckg do
        options '--enablerepo=*-optional'
        package_name pckg
        action :install
      end
    end
  when 'suse'
    ['libGLU1', 'libXdmcp6', 'xorg-x11-server', 'libXfont1'].each do |pckg|
      package @new_resource.recipe_name + ':datastore:' + pckg do
        package_name pckg
        action :install
      end
    end
  else
    # NOTE: ArcGIS products are not officially supported on debian platform family
    ['xserver-common', 'xvfb', 'libfreetype6', 'libfontconfig1', 'libxfont1',
     'libpixman-1-0', 'libgl1-mesa-dri', 'libgl1-mesa-glx', 'libglu1-mesa',
     'libpng12-0', 'x11-xkb-utils', 'libapr1', 'libxrender1', 'libxi6',
     'libxtst6', 'libaio1', 'nfs-kernel-server', 'autofs'].each do |pckg|
      package @new_resource.recipe_name + ':datastore:' + pckg do
        package_name pckg
        action :install
      end
    end
  end

  new_resource.updated_by_last_action(true)
end

action :install do
  if node['platform'] == 'windows'
    cmd = @new_resource.setup
    args = "/qb INSTALLDIR=\"#{@new_resource.install_dir}\" "\
           "USER_NAME=\"#{@new_resource.run_as_user}\" "\
           "PASSWORD=\"#{@new_resource.run_as_password}\""

    installed = ::Win32::Service.exists?('ArcGIS Data Store')

    execute 'Install ArcGIS DataStore' do
      command "\"#{cmd}\" #{args}"
      not_if { installed }
    end

    configureserviceaccount = ::File.join(@new_resource.install_dir,
                                          'tools',
                                          'configureserviceaccount.bat')

    args = "/username #{@new_resource.run_as_user} "\
           "/password #{@new_resource.run_as_password}"

    execute 'datastore.configureserviceaccount' do
      command "cmd.exe /C \"\"#{configureserviceaccount}\" #{args}\""
      only_if { installed }
    end

    properties_filename = ::File.join(@new_resource.install_dir,
                                      'framework',
                                      'etc',
                                      'arcgis-data-store-config.properties')

    hostidentifier_properties_path = ::File.join(@new_resource.install_dir,
                                                 'framework',
                                                 'etc',
                                                 'hostidentifier.properties')

    dir_data = @new_resource.data_dir

    ruby_block 'Set data directory' do
      block do
        if ::File.exist?(properties_filename)
          file = Chef::Util::FileEdit.new(properties_filename)
          file.search_file_replace(/dir.data.*/, "dir.data=#{dir_data}")
          file.write_file
        else
          ::File.open(properties_filename, 'w') { |f| f.write("dir.data=#{dir_data}") }
        end
      end
      not_if { dir_data == node.default['arcgis']['data_store']['data_dir'] }
    end

    ruby_block "Set 'preferredidentifier' in hostidentifier.properties" do
      block do
        file = Chef::Util::FileEdit.new(hostidentifier_properties_path)
        file.search_file_replace(/^preferredidentifier.*/, "preferredidentifier=#{node['arcgis']['data_store']['preferredidentifier']}")
        file.write_file
      end
      not_if { node['arcgis']['data_store']['preferredidentifier'].nil? }
      action :run
    end

    service 'ArcGIS Data Store' do
      action [:enable, :start]
    end

    ruby_block 'Wait for Data Store installation to finish' do
      block do
        sleep(120.0)
      end
    end
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['data_store']['install_subdir'])
    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\""
    run_as_user = @new_resource.run_as_user

    subdir = @new_resource.install_dir
    node['arcgis']['data_store']['install_subdir'].split('/').each do |path|
      subdir = ::File.join(subdir, path)
      directory subdir do
        owner run_as_user
        group 'root'
        mode '0755'
        action :create
      end
    end

    execute 'Setup ArcGIS DataStore' do
      command "su - #{run_as_user} -c \"#{cmd} #{args}\""
      not_if { ::File.exist?(::File.join(install_subdir, 'startdatastore.sh')) }
    end

    dir_data = @new_resource.data_dir

    ruby_block 'Set data directory' do
      block do
        properties_filename = ::File.join(install_subdir,
                                          'framework',
                                          'etc',
                                          'arcgis-data-store-config.properties')

        if ::File.exist?(properties_filename)
          file = Chef::Util::FileEdit.new(properties_filename)
          file.search_file_replace(/dir.data.*/, "dir.data=#{dir_data}")
          file.write_file
        else
          ::File.open(properties_filename, 'w') { |f| f.write("dir.data=#{dir_data}") }
        end
      end
      not_if { dir_data == node.default['arcgis']['data_store']['data_dir'] }
    end

    ruby_block "Set 'preferredidentifier' in hostidentifier.properties" do
      block do
        hostidentifier_properties_path = ::File.join(install_subdir,
                                                     'framework',
                                                     'etc',
                                                     'hostidentifier.properties')

        file = Chef::Util::FileEdit.new(hostidentifier_properties_path)
        file.search_file_replace(/^preferredidentifier.*/, "preferredidentifier=#{node['arcgis']['data_store']['preferredidentifier']}")
        file.write_file
      end
      not_if { node['arcgis']['data_store']['preferredidentifier'].nil? }
      action :run
    end

    configure_autostart(install_subdir)
  end

  new_resource.updated_by_last_action(true)
end

action :uninstall do
  if node['platform'] == 'windows'
    product_code = @new_resource.product_code
    cmd = 'msiexec'
    args = "/qb /x #{product_code}"

    execute 'Uninstall ArcGIS DataStore' do
      command "\"#{cmd}\" #{args}"
      only_if { Utils.product_installed?(product_code) }
    end
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['data_store']['install_subdir'])
    cmd = ::File.join(install_subdir, 'uninstall_ArcGISDataStore')
    args = '-s'

    execute 'Uninstall ArcGIS DataStore' do
      command "su - #{node['arcgis']['run_as_user']} -c \"#{cmd} #{args}\""
      only_if { ::File.exist?(cmd) }
    end
  end

  new_resource.updated_by_last_action(true)
end

action :configure do
  server_admin_url = "#{@new_resource.server_url}/admin"

  ruby_block 'Wait for Server' do
    block do
      Utils.wait_until_url_available(server_admin_url)
    end
    action :run
  end

  if node['platform'] == 'windows'
    cmd = ::File.join(@new_resource.install_dir, 'tools\\configuredatastore')
    args = "\"#{server_admin_url}\" \"#{@new_resource.username}\" \"#{@new_resource.password}\" \"#{@new_resource.data_dir}\" --stores #{@new_resource.types}"
    env = { 'AGSDATASTORE' => @new_resource.install_dir }

    execute 'Configure ArcGIS DataStore' do
      command "\"#{cmd}\" #{args}"
      environment env
      retries 5
      retry_delay 60
    end
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['data_store']['install_subdir'])
    cmd = ::File.join(install_subdir, 'tools/configuredatastore.sh')
    args = "\"#{server_admin_url}\" \"#{@new_resource.username}\" \"#{@new_resource.password}\" \"#{@new_resource.data_dir}\" --stores #{@new_resource.types}"
    run_as_user = @new_resource.run_as_user

    execute 'Configure ArcGIS DataStore' do
      command "\"#{cmd}\" #{args}"
      user run_as_user
    end
  end

  new_resource.updated_by_last_action(true)
end

action :change_backup_location do
  if node['platform'] == 'windows'
    cmd = ::File.join(@new_resource.install_dir, 'tools\\changebackuplocation')
    is_shared_folder = @new_resource.backup_dir.start_with?('\\\\')? 'true' : 'false'
    args = "\"#{@new_resource.backup_dir}\" --is-shared-folder #{is_shared_folder} --keep-old-backups true --prompt no"
    env = { 'AGSDATASTORE' => @new_resource.install_dir }

    execute 'Change ArcGIS DataStore Backup Location' do
      command "\"#{cmd}\" #{args}"
      environment env
    end
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['data_store']['install_subdir'])
    cmd = ::File.join(install_subdir, 'tools/changebackuplocation.sh')
    args = "\"#{@new_resource.backup_dir}\" --is-shared-folder true --keep-old-backups true --prompt no"
    run_as_user = @new_resource.run_as_user

    execute 'Change ArcGIS DataStore Backup Location' do
      command "\"#{cmd}\" #{args}"
      user run_as_user
    end
  end
end

private

def configure_autostart(datastorehome)
  Chef::Log.info('Configure ArcGIS Data Store to be started with the operating system.')

  arcgisdatastore_path = '/etc/init.d/arcgisdatastore'

  if ['rhel', 'centos'].include?(node['platform_family'])
    arcgisdatastore_path = '/etc/rc.d/init.d/arcgisdatastore'
  end

  template arcgisdatastore_path do
    source 'arcgisdatastore.erb'
    variables ({ :datastorehome => datastorehome })
    owner 'root'
    group 'root'
    mode '0755'
    not_if { ::File.exist?(arcgisdatastore_path) }
  end

  service 'arcgisdatastore' do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :restart]
  end

  ruby_block 'Wait for Data Store restart to finish' do
    block do
      sleep(120.0)
    end
  end
end

