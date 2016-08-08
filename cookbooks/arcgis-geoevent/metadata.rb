name             'arcgis-geoevent'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'Installs and configures ArcGIS GeoEvent Extension for Server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.3.0'

depends          'arcgis-server'

supports         'windows'
supports         'ubuntu'
supports         'redhat'

recipe           'arcgis-geoevent::default', 'Installs and configures ArcGIS GeoEvent Extension for Server'
recipe           'arcgis-geoevent::lp-install', 'Installs language pack for ArcGIS GeoEvent Extension for Server.'
recipe           'arcgis-geoevent::uninstall', 'Uninstalls ArcGIS GeoEvent Extension for Server'