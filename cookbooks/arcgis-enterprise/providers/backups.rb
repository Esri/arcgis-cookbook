action :authorize_user do
  carbon_script = ::File.join(node['arcgis']['backups']['carbon_folder'], "Carbon", "Import-Carbon.ps1")
  powershell_script "Authorize user '#{node['arcgis']['run_as_user']}' to logon as batch job" do
    code <<-EOH
    & #{carbon_script}

    $Identity = "#{node['arcgis']['run_as_user']}"
    $privilege = "SeBatchLogonRight"
    Grant-Privilege -Identity $Identity -Privilege $privilege
    EOH
  end
end

action :create_task_server_site_backup do
  windows_task 'ArcGIS Server Site Backup' do
    user node['arcgis']['run_as_user']
    password node['arcgis']['run_as_password']
    force true
    cwd node['arcgis']['python']['python_runtime_environment']
    command 'python.exe "' + node['arcgis']['server']['install_dir'] + '\tools\admin\backup.py" -u ' + node['arcgis']['server']['admin_username'] + ' -p ' + node['arcgis']['server']['admin_password'] + ' -s ' + node['arcgis']['backups']['site_url'] + ' -f "' + node['arcgis']['backups']['site_backup_dir'] + '"'
    frequency :weekly
    frequency_modifier 1
    day 'SAT'
    start_time '20:00'
    action :create
  end
end

action :create_webgis_backup_configuration do
  escaped_backup_path = node['arcgis']['backups']['webgis_backup_dir'].gsub('\\', '\&\&')
  file node['arcgis']['backups']['webgis_backup_configuration_file'] do
    content <<-EOH
    SHARED_LOCATION=#{escaped_backup_path}
    PORTAL_ADMIN_URL = #{node['arcgis']['portal']['url']}
    PORTAL_ADMIN_USERNAME = #{node['arcgis']['portal']['admin_username']}
    PORTAL_ADMIN_PASSWORD = #{node['arcgis']['portal']['admin_password']}
    PORTAL_ADMIN_PASSWORD_ENCRYPTED = false
    INCLUDE_SCENE_TILE_CACHES = #{node['arcgis']['backups']['include_scene_tile_caches']}
    BACKUP_RESTORE_MODE = #{node['arcgis']['backups']['backup_restore_mode']}
    EOH
    rights :full_control, "#{node['arcgis']['run_as_user']}"
    action :create
  end
end

action :create_task_webgis_backup do
  windows_task 'ArcGIS WebGIS Backup' do
    user node['arcgis']['run_as_user']
    password node['arcgis']['run_as_password']
    force true
    cwd ::File.join(node['arcgis']['portal']['install_dir'], "tools", "webgisdr")
    command "webgisdr.bat --export --file #{node['arcgis']['backups']['webgis_backup_configuration_file']}"
    frequency :weekly
    frequency_modifier 1
    day 'SAT'
    start_time '21:00'
    action :create
  end
end

action :create_task_backup_cleanup do
  windows_task 'Cleanup ArcGIS Backups' do
    user node['arcgis']['run_as_user']
    password node['arcgis']['run_as_password']
    force true
    cwd node['arcgis']['misc']['script_directory']
    command "Cleanup_Backups.bat #{node['arcgis']['backups']['webgis_backup_dir']} #{node['arcgis']['backups']['retention_period']}"
    frequency :weekly
    frequency_modifier 1
    day 'SAT'
    start_time '22:00'
    action :create
  end
end