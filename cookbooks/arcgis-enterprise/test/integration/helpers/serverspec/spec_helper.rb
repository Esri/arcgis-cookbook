require 'serverspec'

if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM).nil?
  set :backend, :exec
else
  require 'winrm'
  
  set :backend, :winrm
  set :os, family: 'windows'

  user = 'vagrant'
  pass = 'vagrant'
  endpoint = "http://127.0.0.1:5985/wsman"

  winrm = ::WinRM::WinRMWebService.new(endpoint, :ssl, :user => user, :pass => pass, :basic_auth_only => true)
  winrm.set_timeout 300 # 5 minutes max timeout for any operation
  Specinfra.configuration.winrm = winrm
end
