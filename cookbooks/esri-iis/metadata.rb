name             'esri-iis'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'Enables IIS features required by ArcGIS Web Adaptor (IIS) and configures HTTPS binding.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.0'
chef_version     '>= 15.3' if defined? chef_version

supports         'windows'

recipe 'esri-iis::default', 'Enables IIS features required by ArcGIS Web Adaptor (IIS) and configures HTTPS binding.'
recipe 'esri-iis::install', 'Enables IIS features required by ArcGIS Web Adaptor (IIS).'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
