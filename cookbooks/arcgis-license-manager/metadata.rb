name             'arcgis-license-manager'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'Installs and configures ArcGIS License Manager'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '5.1.0'
chef_version     '>= 15.3' if defined? chef_version

depends          'arcgis-repository', '~> 5.1'
depends          'limits', '~> 2.3'
depends          'java_properties', '~> 0.1'

supports         'windows'
supports         'redhat'
supports         'suse'

recipe           'arcgis-license-manager::default', 'Installs ArcGIS License Manager'
recipe           'arcgis-license-manager::licensemanager', 'Installs ArcGIS License Manager'
recipe           'arcgis-license-manager::uninstall', 'Uninstalls ArcGIS License Manager.'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
