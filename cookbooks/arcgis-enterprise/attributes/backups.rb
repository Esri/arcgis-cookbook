include_attribute 'arcgis-enterprise::server'

default['arcgis']['backups'].tap do |backups|
  backups['site_url'] = 'https://' + node['arcgis']['server']['domain_name'] + '/' + node['arcgis']['server']['wa_name']
  backups['carbon_folder'] = 'D:\\AutomatedDeployment\\AdditionalPowerShellModules\\Carbon'
  backups['include_scene_tile_caches'] = false
  backups['backup_restore_mode'] = 'full' # valid options: 'full' and 'incremental'
  backups['webgis_backup_configuration_file'] = ::File.join(node['arcgis']['portal']['install_dir'], "tools", "webgisdr", "Custom_webgisdr.properties")
  backups['retention_period'] = 30
end