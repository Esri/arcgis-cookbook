name             'arcgis-insights'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'Installs and configures ArcGIS Insights'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '4.1.0'
chef_version     '>= 14.0' if defined? chef_version

depends          'arcgis-enterprise', '~> 4.1'
depends          'arcgis-repository', '~> 4.1'

supports         'windows'
supports         'ubuntu'
supports         'redhat'
supports         'centos'
supports         'oracle'
supports         'suse'

recipe           'arcgis-insights::default', 'Installs and configures ArcGIS Insights'
recipe           'arcgis-insights::install_patches', 'Installs patches for ArcGIS Insights'
recipe           'arcgis-insights::uninstall', 'Uninstalls ArcGIS Insights'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
