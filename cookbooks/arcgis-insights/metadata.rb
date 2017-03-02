name             'arcgis-insights'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'Installs and configures Insights for ArcGIS'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.0.0'

depends          'arcgis-enterprise'

supports         'windows'
supports         'ubuntu'
supports         'redhat'

recipe           'arcgis-insights::default', 'Installs and configures Insights for ArcGIS'
recipe           'arcgis-insights::uninstall', 'Uninstalls Insights for ArcGIS'