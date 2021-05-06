name             'arcgis'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'ArcGIS Chef Cookbooks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.7.0'
chef_version     '>= 13.0' if defined? chef_version

depends          'arcgis-desktop', '~> 3.7'
depends          'arcgis-egdb', '~> 1.0'
depends          'arcgis-enterprise', '~> 3.7'
depends          'arcgis-geoevent', '~> 3.7'
depends          'arcgis-notebooks', '~> 3.7'
depends          'arcgis-mission', '~> 3.7'
depends          'arcgis-insights', '~> 3.7'
depends          'arcgis-pro', '~> 3.7'
depends          'arcgis-repository', '~> 3.7'
depends          'esri-iis', '~> 0.1'
depends          'esri-tomcat', '~> 0.1'

supports         'windows'
supports         'ubuntu'
supports         'redhat'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
