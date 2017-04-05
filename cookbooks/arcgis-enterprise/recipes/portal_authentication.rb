arcgis_enterprise_portal_authentication 'Disabling users ability to create built-in Portal accounts' do
  portal_url node['arcgis']['portal']['url']
  username node['arcgis']['portal']['admin_username']
  password node['arcgis']['portal']['admin_password']
  only_if { node['arcgis']['portal']['authentication']['disable_signup'] }
  action :disable_signup
end

if node['platform'] == 'windows'
  arcgis_enterprise_portal_authentication 'Configure Portal to use Active Directory for user accounts' do
    portal_url node['arcgis']['portal']['url']
    username node['arcgis']['portal']['admin_username']
    password node['arcgis']['portal']['admin_password']
    active_directory_username node['arcgis']['run_as_user']
    active_directory_password node['arcgis']['run_as_password']
    only_if { node['arcgis']['portal']['authentication']['configure_active_directory_users'] }
    action :use_windows_users
  end
  
  arcgis_enterprise_portal_authentication 'Enable Windows Authentication within IIS (Single Sign-On)' do
    wa_name node['arcgis']['portal']['wa_name']
    only_if { node['arcgis']['portal']['authentication']['enable_single_sign_on'] }
    action :enable_iis_windows_authentication
  end
  
  arcgis_enterprise_portal_authentication 'Disable Anonymous Authentication within IIS (Single Sign-On)' do
    wa_name node['arcgis']['portal']['wa_name']
    only_if { node['arcgis']['portal']['authentication']['enable_single_sign_on'] }
    action :disable_iis_anonymous_authentication
  end
  
  arcgis_enterprise_portal_authentication 'Add IE 11 Compatibility Header to Portal config within IIS' do
    wa_name node['arcgis']['portal']['wa_name']
    action :add_iis_ie11_compatibility_header
  end
end