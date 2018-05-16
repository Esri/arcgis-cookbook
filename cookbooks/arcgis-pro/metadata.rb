name             'arcgis-pro'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'Installs and configures ArcGIS Pro'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.2.0'

depends          'windows'

supports         'windows'

recipe 'arcgis-pro::default', 'Installs ArcGIS Pro'
recipe 'arcgis-pro::uninstall', 'Uninstalls ArcGIS Pro'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
