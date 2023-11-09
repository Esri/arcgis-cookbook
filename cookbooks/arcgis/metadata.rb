name             'arcgis'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'ArcGIS Chef Cookbooks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '4.2.0'
chef_version     '>= 14.0' if defined? chef_version

depends          'arcgis-desktop', '~> 4.2'
depends          'arcgis-egdb', '~> 1.1'
depends          'arcgis-enterprise', '~> 4.2'
depends          'arcgis-geoevent', '~> 4.2'
depends          'arcgis-notebooks', '~> 4.2'
depends          'arcgis-mission', '~> 4.2'
depends          'arcgis-insights', '~> 4.2'
depends          'arcgis-pro', '~> 4.2'
depends          'arcgis-repository', '~> 4.2'
depends          'arcgis-workflow-manager', '~> 4.2'
depends          'esri-iis', '~> 0.2'
depends          'esri-tomcat', '~> 0.2'

supports         'windows'
supports         'ubuntu'
supports         'redhat'
supports         'centos'
supports         'oracle'
supports         'suse'
supports         'rocky'
supports         'almalinux'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
