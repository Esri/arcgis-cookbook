name 'arcgis-mission'
maintainer 'Esri'
maintainer_email 'contracts@esri.com'
license 'Apache-2.0'
description 'Installs/Configures ArcGIS Mission Server'
long_description 'Installs/Configures ArcGIS Mission Server'
version '3.6.1'
chef_version '>= 13.0' if defined? chef_version

depends          'arcgis-enterprise', '~> 3.6'
depends          'arcgis-repository', '~> 3.6'

supports         'ubuntu'
supports         'redhat'
supports         'windows'

recipe 'arcgis-mission::default', 'Installs and configures ArcGIS Mission Server'
recipe 'arcgis-mission::federation', 'Federates ArcGIS Mission Server with Portal for ArcGIS and enables MissionServer role'
recipe 'arcgis-mission::install_server', 'Installs ArcGIS Mission Server'
recipe 'arcgis-mission::install_server_wa', 'Installs ArcGIS Web Adaptor for ArcGIS Mission Server'
recipe 'arcgis-mission::server', 'Installs and configures ArcGIS Mission Server'
recipe 'arcgis-mission::server_wa', 'Installs and configures ArcGIS Web Adaptor for ArcGIS Mission Server'
recipe 'arcgis-mission::uninstall_server', 'Uninstalls ArcGIS Mission Server'
recipe 'arcgis-mission::uninstall_server_wa', 'Uninstalls ArcGIS Web Adaptor for ArcGIS Mission Server'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
