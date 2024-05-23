name 'arcgis-video'
maintainer 'Esri'
maintainer_email 'contracts@esri.com'
license 'Apache-2.0'
description 'Installs/Configures ArcGIS Video Server'
long_description 'Installs/Configures ArcGIS Video Server'
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

recipe 'arcgis-video::default', 'Installs and configures ArcGIS Video Server'
recipe 'arcgis-video::federation', 'Federates ArcGIS Video Server with Portal for ArcGIS and enables VideoServer role'
recipe 'arcgis-video::install_patches', 'Installs patches for ArcGIS Video Server'
recipe 'arcgis-video::install_server', 'Installs ArcGIS Video Server'
recipe 'arcgis-video::install_server_wa', 'Installs ArcGIS Web Adaptor for ArcGIS Video Server'
recipe 'arcgis-video::server', 'Installs and configures ArcGIS Video Server'
recipe 'arcgis-video::server_wa', 'Installs and configures ArcGIS Web Adaptor for ArcGIS Video Server'
recipe 'arcgis-video::uninstall_server', 'Uninstalls ArcGIS Video Server'
recipe 'arcgis-video::uninstall_server_wa', 'Uninstalls ArcGIS Web Adaptor for ArcGIS Video Server'
recipe 'arcgis-video::unregister_server_wa', 'Unregisters all ArcGIS Video Server Web Adaptors'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
