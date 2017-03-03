name             'esri-iis'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache 2.0'
description      'Enables IIS features required by ArcGIS Web Adaptor (IIS) and configures HTTPS binding.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends          'windows'
depends          'openssl'

supports         'windows'

recipe 'esri-iis::default', 'Enables IIS features required by ArcGIS Web Adaptor (IIS) and configures HTTPS binding.'