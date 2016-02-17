#
# Cookbook Name:: arcgis
# Provider:: server
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

action :system do
  arcgis_user @new_resource.recipe_name + ':create-server-account'

  case node['platform']
  when 'windows'
    # Install .Net Framework
    if node['platform_version'].to_f < 6.3
      node.default['ms_dotnet']['v4']['version'] = '4.5.1'
      @run_context.include_recipe 'ms_dotnet::ms_dotnet4'
    end
  when 'redhat', 'centos'
    ['mesa-libGLU', 'libXdmcp', 'xorg-x11-server-Xvfb'].each do |pckg|
      yum_package @new_resource.recipe_name + ':server:' + pckg do
        options '--enablerepo=*-optional'
        package_name pckg
        action :install
      end
    end
  when 'suse'
    ['libGLU1', 'libXdmcp6', 'xorg-x11-server', 'libXfont1'].each do |pckg|
      package @new_resource.recipe_name + ':server:' + pckg do
        package_name pckg
        action :install
      end
    end
  else
    # NOTE: ArcGIS products are not officially supported on debian linux family
    ['xserver-common', 'xvfb', 'libfreetype6', 'libfontconfig1', 'libxfont1',
     'libpixman-1-0', 'libgl1-mesa-dri', 'libgl1-mesa-glx', 'libglu1-mesa',
     'libpng12-0', 'x11-xkb-utils', 'libapr1', 'libxrender1', 'libxi6',
     'libxtst6', 'libaio1', 'nfs-kernel-server', 'autofs'].each do |pckg|
      package @new_resource.recipe_name + ':server:' + pckg do
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
    args = "/qb INSTALLDIR=\"#{@new_resource.install_dir}\" INSTALLDIR1=\"#{@new_resource.python_dir}\" USER_NAME=\"#{@new_resource.run_as_user}\" PASSWORD=\"#{@new_resource.run_as_password}\""
    install_dir = @new_resource.install_dir
    run_as_user = @new_resource.run_as_user
    run_as_password = @new_resource.run_as_password

    installed = Utils.product_installed?(node['arcgis']['server']['product_code'])

    execute 'Install ArcGIS for Server' do
      command "\"#{cmd}\" #{args}"
      not_if { installed }
    end

    if run_as_user.include? '\\'
      service_logon_user = run_as_user
    else
      service_logon_user = ".\\#{run_as_user}"
    end

    execute "Stop 'ArcGIS Server' service" do
      command "net stop \"ArcGIS Server\" /yes"
      retries 10
      retry_delay 60
      only_if { installed }
    end

    execute "Change 'ArcGIS Server' service logon account" do
      command "sc.exe config \"ArcGIS Server\" obj= \"#{service_logon_user}\" password= \"#{run_as_password}\""
      only_if { installed }
      # sensitive true
    end

    execute "Start 'ArcGIS Server' service" do
      command "net start \"ArcGIS Server\" /yes"
      retries 5
      retry_delay 60
      only_if { installed }
    end

    ruby_block "Wait for 'ArcGIS Server' service to start" do
      block do
        sleep(120.0)
      end
    end
  else
    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\""
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['server']['install_subdir'])
    run_as_user = @new_resource.run_as_user

    subdir = @new_resource.install_dir
    node['arcgis']['server']['install_subdir'].split('/').each do |path|
      subdir = ::File.join(subdir, path)
      directory subdir do
        owner run_as_user
        group 'root'
        mode '0755'
        action :create
      end
    end

    execute 'Install ArcGIS for Server' do
      command "su - #{run_as_user} -c \"#{cmd} #{args}\""
      only_if { !::File.exist?(::File.join(install_subdir, 'startserver.sh')) }
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

    execute 'Uninstall ArcGIS for Server' do
      command "\"#{cmd}\" #{args}"
      only_if { Utils.product_installed?(product_code) }
    end
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['server']['install_subdir'])
    cmd = ::File.join(install_subdir, 'uninstall_ArcGISServer')
    args = '-s'

    service 'arcgisserver' do
      action :stop
    end

    execute 'Uninstall ArcGIS for Server' do
      command "su - #{node['arcgis']['run_as_user']} -c \"#{cmd} #{args}\""
      only_if { ::File.exist?(cmd) }
    end
  end

  new_resource.updated_by_last_action(true)
end

action :authorize do
  cmd = node['arcgis']['server']['authorization_tool']

  if node['platform'] == 'windows'
    args = "/VER #{@new_resource.authorization_file_version} /LIF \"#{@new_resource.authorization_file}\" /S"

    execute 'Authorize ArcGIS for Server' do
      command "\"#{cmd}\" #{args}"
      retries 3
      retry_delay 60
    end
  else
    args = "-f \"#{@new_resource.authorization_file}\""

    execute 'Authorize ArcGIS for Server' do
      command "\"#{cmd}\" #{args}"
      user node['arcgis']['run_as_user']
      retries 3
      retry_delay 60
    end
  end

  new_resource.updated_by_last_action(true)
end

action :create_site do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  admin_client.wait_until_available

  if admin_client.site_exist?
    Chef::Log.warn('ArcGIS Server site already exists.')
  else
    Chef::Log.info('Creating ArcGIS Server site...')

    admin_client.create_site(@new_resource.server_directories_root,
                             @new_resource.config_store_type,
                             @new_resource.config_store_connection_string,
                             @new_resource.config_store_connection_secret)

    admin_client.wait_until_available

    Chef::Log.info('Updating ArcGIS Server system properties...')

    admin_client.update_system_properties(@new_resource.system_properties)

    new_resource.updated_by_last_action(true)
  end
end

action :join_site do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  admin_client.wait_until_available

  if admin_client.site_exist?
    Chef::Log.warn('Machine is already connected to an ArcGIS Server site.')
  else
    primary_admin_client = ArcGIS::ServerAdminClient.new(
      @new_resource.primary_server_url,
      @new_resource.username,
      @new_resource.password)

    primary_admin_client.wait_until_site_exist

    admin_client.join_site(@new_resource.primary_server_url)

    new_resource.updated_by_last_action(true)
  end
end

action :join_cluster do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  admin_client.wait_until_available

  machine_name = admin_client.local_machine_name

  admin_client.add_machine_to_cluster(machine_name, @new_resource.cluster)

  new_resource.updated_by_last_action(true)
end

action :configure_https do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  machine_name = admin_client.local_machine_name

  cert_alias = admin_client.get_server_ssl_certificate(machine_name)

  unless cert_alias == @new_resource.cert_alias
    unless admin_client.ssl_certificate_exist?(machine_name, @new_resource.cert_alias)
      admin_client.import_server_ssl_certificate(machine_name,
                                                 @new_resource.keystore_file,
                                                 @new_resource.keystore_password,
                                                 @new_resource.cert_alias)
    end

    admin_client.set_server_ssl_certificate(machine_name, @new_resource.cert_alias)

    sleep(60.0)

    admin_client.wait_until_available

    new_resource.updated_by_last_action(true)
  end
end

action :register_database do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  admin_client.register_database(@new_resource.data_item_path,
                                 @new_resource.connection_string,
                                 @new_resource.is_managed)

  new_resource.updated_by_last_action(true)
end

action :federate do
  server_id = @new_resource.server_id
  secret_key = @new_resource.secret_key

  server_id = node['arcgis']['server']['server_id'] if server_id.nil?

  secret_key = node['arcgis']['server']['secret_key'] if secret_key.nil?

  if !server_id.nil? && !secret_key.nil?
    portal_admin_client = ArcGIS::PortalAdminClient.new(
      @new_resource.portal_url,
      @new_resource.portal_username,
      @new_resource.portal_password)

    portal_admin_client.wait_until_available

    portal_token = portal_admin_client.generate_token(
      @new_resource.portal_url + '/sharing/generateToken')

    server_admin_client = ArcGIS::ServerAdminClient.new(
      @new_resource.server_url,
      @new_resource.username,
      @new_resource.password)

    server_admin_client.wait_until_available

    server_admin_client.federate(@new_resource.portal_url,
                                 portal_token,
                                 server_id,
                                 secret_key)

    new_resource.updated_by_last_action(true)
  end
end

private

def configure_autostart(agshome)
  Chef::Log.info('Configure ArcGIS for Server to be started with the operating system.')

  arcgisserver_path = '/etc/init.d/arcgisserver'

  if ['rhel', 'centos'].include?(node['platform_family'])
    arcgisserver_path = '/etc/rc.d/init.d/arcgisserver'
  end

  template arcgisserver_path do
    source 'arcgisserver.erb'
    variables ({ :agshome => agshome })
    owner 'root'
    group 'root'
    mode '0755'
    only_if { !::File.exist?(arcgisserver_path) }
  end

  service 'arcgisserver' do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :start]
  end
end
