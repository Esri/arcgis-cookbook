default['arcgis']['portal']['authentication'].tap do |portal_authentication|
  portal_authentication['disable_signup'] = false
  portal_authentication['configure_active_directory_users'] = false
  portal_authentication['enable_single_sign_on'] = false
end