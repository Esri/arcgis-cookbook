name             'esri-tomcat'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'Installs/Configures esri-tomcat'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'
chef_version     '>= 14.0'

depends          'tomcat', '>= 3.2.0'
depends          'openssl', '~> 8.5'
depends          'iptables', '~> 7.1'

%w(ubuntu redhat centos oracle suse).each do |os|
  supports os
end

recipe 'esri-tomcat::default', 'Installs and configures Apache Tomcat application server for ArcGIS Web Adaptor.'
recipe 'esri-tomcat::install', 'Installs Apache Tomcat application server.'
recipe 'esri-tomcat::configure_ssl', 'Configures HTTPS listener in Apache Tomcat application server.'
recipe 'esri-tomcat::iptables', 'Installs iptables and configures HTTP(S) port forwarding (80 to 8080 and 443 to 8443).' 
recipe 'esri-tomcat::firewalld', 'Installs FirewallD and configures HTTP(S) port forwarding (80 to 8080 and 443 to 8443).' 
recipe 'esri-tomcat::openjdk', 'Installs OpenJDK for Apache Tomcat from a local or remote tarball.'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
