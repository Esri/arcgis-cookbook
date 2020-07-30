name             'esri-tomcat'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'Installs/Configures esri-tomcat'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.7'
chef_version     '>= 13'

depends          'tomcat', '>= 3.2.0'
depends          'openssl', '~> 8.5'

%w(ubuntu redhat centos).each do |os|
  supports os
end

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
