name 'arcgis-notebooks'
maintainer 'Esri'
maintainer_email 'contracts@esri.com'
license 'Apache-2.0'
description 'Installs/Configures ArcGIS Notebook Server'
long_description 'Installs/Configures ArcGIS Notebook Server'
version '3.6.1'
chef_version '>= 13.0' if defined? chef_version

depends          'arcgis-enterprise', '~> 3.6'
depends          'arcgis-repository', '~> 3.6'
depends          'docker', '~> 4.9'

supports         'ubuntu'
supports         'redhat'
supports         'windows'

recipe 'arcgis-notebooks::default', 'Installs and configures ArcGIS Notebook Server'
recipe 'arcgis-notebooks::docker', 'Installs Docker engine'
recipe 'arcgis-notebooks::federation', 'Federates ArcGIS Notebook Server with Portal for ArcGIS and enables NotebookServer role'
recipe 'arcgis-notebooks::install_server', 'Installs ArcGIS Notebook Server'
recipe 'arcgis-notebooks::install_server_wa', 'Installs ArcGIS Web Adaptor for ArcGIS Notebook Server'
recipe 'arcgis-notebooks::server', 'Installs and configures ArcGIS Notebook Server'
recipe 'arcgis-notebooks::server_node', 'Joins additional machines to an ArcGIS Notebook Server site'
recipe 'arcgis-notebooks::server_wa', 'Installs and configures ArcGIS Web Adaptor for ArcGIS Notebook Server'
recipe 'arcgis-notebooks::uninstall_server', 'Uninstalls ArcGIS Notebook Server'
recipe 'arcgis-notebooks::uninstall_server_wa', 'Uninstalls ArcGIS Web Adaptor for ArcGIS Notebook Server'
recipe 'arcgis-notebooks::unregister_machine', 'Unregisters server machine from the ArcGIS Notebook Server site'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
