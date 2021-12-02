name             'arcgis'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'ArcGIS Chef Cookbooks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.8.0'
chef_version     '>= 13.0' if defined? chef_version

depends          'arcgis-desktop', '~> 3.8'
depends          'arcgis-egdb', '~> 1.0'
depends          'arcgis-enterprise', '~> 3.8'
depends          'arcgis-geoevent', '~> 3.8'
depends          'arcgis-notebooks', '~> 3.8'
depends          'arcgis-mission', '~> 3.8'
depends          'arcgis-insights', '~> 3.8'
depends          'arcgis-pro', '~> 3.8'
depends          'arcgis-repository', '~> 3.8'
depends          'arcgis-workflow-manager', '~> 3.8'
depends          'esri-iis', '~> 0.1'
depends          'esri-tomcat', '~> 0.1'

supports         'windows'
supports         'ubuntu'
supports         'redhat'
supports         'centos'
supports         'oracle'
supports         'suse'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
