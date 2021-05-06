default['tomcat']['version'] = '8.5.63'

default['tomcat']['instance_name'] = 'arcgis'
default['tomcat']['install_path'] = '/opt/tomcat_' + node['tomcat']['instance_name'] + '_' + node['tomcat']['version']
default['tomcat']['tarball_path'] = "#{Chef::Config['file_cache_path']}/apache-tomcat-#{node['tomcat']['version']}.tar.gz"

default['tomcat']['user'] = 'tomcat_' + node['tomcat']['instance_name']
default['tomcat']['group'] = 'tomcat_' + node['tomcat']['instance_name']

default['tomcat']['ssl_enabled_protocols'] ='TLSv1.2,TLSv1.1,TLSv1'
default['tomcat']['keystore_file']  = ''
if ENV['TOMCAT_KEYSTORE_PASSWORD'].nil?
  default['tomcat']['keystore_password']  = ''
else
  default['tomcat']['keystore_password']  = ENV['TOMCAT_KEYSTORE_PASSWORD']
end
default['tomcat']['keystore_type']  = 'PKCS12'
default['tomcat']['domain_name']  = node['fqdn']
default['tomcat']['verify_checksum'] = true

default['java']['version'] = '11'
default['java']['tarball_uri'] = 'https://download.java.net/java/ga/jdk11/openjdk-11_linux-x64_bin.tar.gz'
default['java']['tarball_path'] = "#{Chef::Config['file_cache_path']}/openjdk-#{node['java']['version']}_linux-x64_bin.tar.gz"
default['java']['install_path'] = '/opt'

default['tomcat']['forward_ports'] = true
default['tomcat']['firewalld']['init_cmd'] = 'firewall-cmd --zone=public --permanent --add-port=0-65535/tcp'
