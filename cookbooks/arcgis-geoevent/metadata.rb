name             'arcgis-geoevent'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'Installs and configures ArcGIS GeoEvent Server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.4.0'
chef_version     '>= 12.6', '< 15.0' if defined? chef_version

depends          'arcgis-enterprise', '~> 3.4'
depends          'arcgis-repository', '~> 3.4'

supports         'windows'
supports         'ubuntu'
supports         'redhat'

recipe           'arcgis-geoevent::default', 'Installs and configures ArcGIS GeoEvent Server'
recipe           'arcgis-geoevent::lp-install', 'Installs language pack for ArcGIS GeoEvent Server.'
recipe           'arcgis-geoevent::uninstall', 'Uninstalls ArcGIS GeoEvent Server'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
