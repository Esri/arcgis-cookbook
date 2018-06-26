action :disable_signup do
  portal_admin_client = ArcGIS::PortalAdminClient.new(
    @new_resource.portal_url,
    @new_resource.username,
    @new_resource.password)

  portal_admin_client.wait_until_available

  # avoid loosing existing system properties
  # => get all existing system properties and append the new one
  system_properties = portal_admin_client.get_system_properties
  system_properties['disableSignup'] = true

  portal_admin_client.update_system_properties(system_properties)
  
  # after updating the system properties, Portal get's restarted automatically
  # => wait until Portal is available again before continuing
  sleep(90.0)

  new_resource.updated_by_last_action(true)
end

action :use_windows_users do
  portal_admin_client = ArcGIS::PortalAdminClient.new(
    @new_resource.portal_url,
    @new_resource.username,
    @new_resource.password)

  portal_admin_client.wait_until_available
  
  security_configuration = portal_admin_client.get_security_configuration

  user_store_config = {
    'type' => "WINDOWS",
    'properties' => {
      'isPasswordEncrypted' => false,
      'user' => @new_resource.active_directory_username,
      'userPassword' => @new_resource.active_directory_password
    }
  }
  
  group_store_config = security_configuration['groupStoreConfig']
      
  portal_admin_client.set_identity_store(user_store_config, group_store_config)

  portal_admin_client.wait_until_available
end

action :enable_iis_windows_authentication do
  portal_wa_name = @new_resource.wa_name
  execute 'Enable Windows Authentication for Portal within IIS' do
    command "%systemroot%\\system32\\inetsrv\\appcmd.exe set config \"Default Web Site/#{portal_wa_name}\" -section:system.webServer/security/authentication/windowsAuthentication /enabled:\"True\" /commit:apphost"
  end
end

action :disable_iis_anonymous_authentication do
  portal_wa_name = @new_resource.wa_name
  execute 'Disable Anonymous Authentication for Portal within IIS' do
    command "%systemroot%\\system32\\inetsrv\\appcmd.exe set config \"Default Web Site/#{portal_wa_name}\" -section:system.webServer/security/authentication/anonymousAuthentication /enabled:\"False\" /commit:apphost"
  end
end

action :add_iis_ie11_compatibility_header do
  portal_wa_name = @new_resource.wa_name
  ruby_block 'Add IE 11 Compatibility Header' do
    block do
      # get Portal's current configuration within IIS
      Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)      
      command = "%systemroot%\\system32\\inetsrv\\appcmd.exe list config \"Default Web Site/#{portal_wa_name}\" -section:system.webServer/httpProtocol"
      command_out = shell_out(command)
      command_out.error!
      command_stdout = command_out.stdout
      
      # check whether the Compatibility Header is already set
      if (command_stdout.include? "X-UA-Compatible") && (command_stdout.include? "IE=11")
        Chef::Log.info('IE 11 Compatibility Header is already configured for Portal')
      else
        command = "%systemroot%\\system32\\inetsrv\\appcmd.exe set config \"Default Web Site/#{portal_wa_name}\" -section:system.webServer/httpProtocol /+customHeaders.[name='X-UA-Compatible',value='IE=11']"
        command_out = shell_out(command)
        command_out.error!
      end
    end
    action :create
  end
end