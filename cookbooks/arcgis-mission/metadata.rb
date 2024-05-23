name 'arcgis-mission'
maintainer 'Esri'
maintainer_email 'contracts@esri.com'
license 'Apache-2.0'
description 'Installs/Configures ArcGIS Mission Server'
long_description 'Installs/Configures ArcGIS Mission Server'
version '5.0.0'
chef_version '>= 15.3' if defined? chef_version

depends          'arcgis-enterprise', '~> 5.0'
depends          'arcgis-repository', '~> 5.0'

supports         'ubuntu'
supports         'redhat'
supports         'centos'
supports         'oracle'
supports         'suse'
supports         'windows'

recipe 'arcgis-mission::default', 'Installs and configures ArcGIS Mission Server'
recipe 'arcgis-mission::federation', 'Federates ArcGIS Mission Server with Portal for ArcGIS and enables MissionServer role'
recipe 'arcgis-mission::fileserver', 'Configures shared directories for ArcGIS Mission Server on file server machine'
recipe 'arcgis-mission::install_patches', 'Installs patches for ArcGIS Mission Server'
recipe 'arcgis-mission::install_server', 'Installs ArcGIS Mission Server'
recipe 'arcgis-mission::install_server_wa', 'Installs ArcGIS Web Adaptor for ArcGIS Mission Server'
recipe 'arcgis-mission::server', 'Installs and configures ArcGIS Mission Server'
recipe 'arcgis-mission::server_node', 'Joins additional machines to ArcGIS Mission Server site'
recipe 'arcgis-mission::server_wa', 'Installs and configures ArcGIS Web Adaptor for ArcGIS Mission Server'
recipe 'arcgis-mission::uninstall_server', 'Uninstalls ArcGIS Mission Server'
recipe 'arcgis-mission::uninstall_server_wa', 'Uninstalls ArcGIS Web Adaptor for ArcGIS Mission Server'
recipe 'arcgis-mission::unregister_machine', 'Unregisters server machine from ArcGIS Mission Server site'
recipe 'arcgis-mission::unregister_server_wa', 'Unregisters all ArcGIS Mission Server Web Adaptors'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
