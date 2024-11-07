name             'arcgis'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'ArcGIS Chef Cookbooks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '5.1.0'
chef_version     '>= 15.3' if defined? chef_version

depends          'arcgis-license-manager', '~> 5.1'
depends          'arcgis-egdb', '~> 2.1'
depends          'arcgis-enterprise', '~> 5.1'
depends          'arcgis-geoevent', '~> 5.1'
depends          'arcgis-notebooks', '~> 5.1'
depends          'arcgis-mission', '~> 5.1'
depends          'arcgis-insights', '~> 5.1'
depends          'arcgis-pro', '~> 5.1'
depends          'arcgis-repository', '~> 5.1'
depends          'arcgis-workflow-manager', '~> 5.1'
depends          'arcgis-video', '~> 5.1'
depends          'esri-iis', '~> 0.3'
depends          'esri-tomcat', '~> 0.3'

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
