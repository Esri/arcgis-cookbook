name 'arcgis-workflow-manager'
maintainer 'Esri'
maintainer_email 'contracts@esri.com'
license 'Apache-2.0'
description 'Installs/Configures ArcGIS Workflow Manager Server and Web App'
long_description 'Installs/Configures ArcGIS Workflow Manager Server and Web App'
version '4.1.0'
chef_version '>= 14.0'

depends          'arcgis-enterprise', '~> 4.1'
depends          'arcgis-repository', '~> 4.1'

supports         'windows'
supports         'ubuntu'
supports         'redhat'
supports         'centos'
supports         'oracle'
supports         'suse'

recipe           'arcgis-workflow-manager::default', 'Installs and authorizes ArcGIS Workflow Manager Server'
recipe           'arcgis-workflow-manager::federation', 'Federates ArcGIS Workflow Manager Server and enables Workflow Manager server function'
recipe           'arcgis-workflow-manager::install_patches', 'Installs patches for ArcGIS Workflow Manager Server'
recipe           'arcgis-workflow-manager::install_server', 'Installs ArcGIS Workflow Manager Server'
recipe           'arcgis-workflow-manager::install_webapp', 'Installs ArcGIS Workflow Manager Web App'
recipe           'arcgis-workflow-manager::server', 'Installs and authorizes ArcGIS Workflow Manager Server'
recipe           'arcgis-workflow-manager::uninstall_server', 'Uninstalls ArcGIS Workflow Manager Server'
recipe           'arcgis-workflow-manager::uninstall_webapp', 'Uninstalls ArcGIS Workflow Manager Web App'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
