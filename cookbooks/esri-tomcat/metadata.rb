name 'esri-tomcat'
maintainer 'Esri'
maintainer_email 'contracts@esri.com'
license 'Apache 2.0'
description 'Installs/Configures esri-tomcat'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'tomcat', '>= 2.3.0'
depends 'java'
depends 'openssl'
