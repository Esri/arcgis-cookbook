arcgis_enterprise_datasources 'Create ArcGIS Server connection file' do
  admin_user node['arcgis']['server']['admin_username']
  admin_password node['arcgis']['server']['admin_password']
  action :create_ags_connection_file
end

# register folders
if !node['arcgis']['datasources']['folders'].nil?
  node['arcgis']['datasources']['folders'].each do |folder|
    # retrieve strategy regarding folder creation, security, sharing and publishing of the current folder
    if folder['create_folder'].nil? || folder['create_folder'] == false
      create_folder = false
    else
      create_folder = true
      
      # should the Windows Service Account of ArcGIS Server be authorized?
      if folder['security_permissions']['authorize_arcgis_service_account'].nil? || folder['security_permissions']['authorize_arcgis_service_account'] == false
        authorize_arcgis_service_account = false
      else
        authorize_arcgis_service_account = true
      end
    end
    
    if folder['share_folder'].nil? || folder['share_folder'] == false
      share_folder = false
    else
      share_folder = true
    end
    
    # should the folder be registered within ArcGIS Server?
    if folder['publish_folder'].nil?
      publish_folder = false
    else
      publish_folder = true
      
      # should the folder be registered with it's hostname?
      if folder['publish_folder']['publish_with_hostname'].nil? || folder['publish_folder']['publish_with_hostname'] == false
        publish_with_hostname = false
      else
        publish_with_hostname = true
      end
      
      # should the folder be registered with it's fully qualified domain name?
      if folder['publish_folder']['publish_with_fqdn'].nil? || folder['publish_folder']['publish_with_fqdn'] == false
        publish_with_fqdn = false
      else
        publish_with_fqdn = true
      end
      
      # should the folder be registered with an alternative path?
      if folder['publish_folder']['publish_alternative_path'].nil? || folder['publish_folder']['publish_alternative_path'] == false
        publish_with_alternative_path = false
      else
        publish_with_alternative_path = true
      end
    end
    
    # create/update folder and set privileges for the configured members
    arcgis_enterprise_datasources "Create folder #{folder['server_path']}" do
      authorize_arcgis_service_account authorize_arcgis_service_account
      folder folder
      only_if { create_folder }
      action :create_folder
    end
    
    arcgis_enterprise_datasources "Share folder #{folder['server_path']}" do
      folder folder
      only_if { share_folder }
      action :share_folder
    end
       
    # register folder within ArcGIS Server
    arcgis_enterprise_datasources "Register folder #{folder['server_path']} in ArcGIS Server" do
      folder folder
      publish_with_hostname publish_with_hostname
      publish_with_fqdn publish_with_fqdn
      publish_with_alternative_path publish_with_alternative_path
      only_if { publish_folder }
      action :register_folder
    end
  end
end

# register SDE connections
if !node['arcgis']['datasources']['sde_files'].nil?
  arcgis_enterprise_datasources 'Register SDE files from folder as data source within ArcGIS Server' do
    not_if { node['arcgis']['datasources']['sde_files']['folder'].nil? }
    action :register_sde_files_from_folder
  end
  
  arcgis_enterprise_datasources 'Register SDE files as data source within ArcGIS Server' do
    not_if { node['arcgis']['datasources']['sde_files']['files'].nil? }
    action :register_sde_files
  end
end

arcgis_enterprise_datasources 'Delete ArcGIS Server connection file' do
  action :delete_ags_connection_file
end

arcgis_enterprise_server 'Block the automatic copying of data to the server at publish time' do
  server_url node['arcgis']['server']['url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  only_if { node['arcgis']['datasources']['block_data_copy'] }
  action :block_data_copy
end