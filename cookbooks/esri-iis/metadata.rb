name             'esri-iis'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'Enables IIS features required by ArcGIS Web Adaptor (IIS) and configures HTTPS binding.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.3'

depends          'windows', '~> 5.3'
depends          'openssl', '~> 8.5'

supports         'windows'

recipe 'esri-iis::default', 'Enables IIS features required by ArcGIS Web Adaptor (IIS) and configures HTTPS binding.'
recipe 'esri-iis::install', 'Enables IIS features required by ArcGIS Web Adaptor (IIS).'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
