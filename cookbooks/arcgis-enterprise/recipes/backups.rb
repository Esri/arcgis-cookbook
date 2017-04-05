if node['platform'] == 'windows'
  arcgis_enterprise_backups 'Authorize backup user' do
    action :authorize_user
  end
    
  if Dir.exists? "#{node['arcgis']['portal']['install_dir']}"
    arcgis_enterprise_backups 'Create configuration file for ArcGIS WebGIS backups' do
      action :create_webgis_backup_configuration
    end
    
    arcgis_enterprise_backups 'Create Scheduled Task for ArcGIS WebGIS backups' do
      action :create_task_webgis_backup
    end
  elsif Dir.exists? "#{node['arcgis']['server']['install_dir']}"
    arcgis_enterprise_backups 'Create Scheduled Task to backup ArcGIS Server Site' do
      action :create_task_server_site_backup
    end
  end
  
  arcgis_enterprise_backups 'Create Scheduled Task for backup cleanup' do
    action :create_task_backup_cleanup
  end
end