arcgis cookbook CHANGELOG
================

This file is used to list changes made in each version of the arcgis cookbook.

2.2.1
-----
- ArcGIS 10.4.1 support.

2.2.0
-----
- This version supports only ArcGIS 10.4 release software. (Use 1.1.3 version with ArcGIS software 10.3.1 release.)
- Added 'all_uninstalled' and 'cleanup' recipes
- Added 'arcgis' top level key to all arcgis cookbook attributes
- Added support for ArcGIS Pro
- Using 10.4 federation and HA workflows 
- Data Store types made configurable (see node['arcgis']['data_store']['types'] attribute)
- Added :uninstall action to geoevent resource

1.1.3
-----
- Added ArcGIS GeoEvent Extension for Server resource
- Default value of attribute node['data_store']['preferredidentifier'] set to 'hostname' instead of 'ip' 

1.1.2
-----
- Support configuration of highly available Portal for ArcGIS
- Fixed problem with NetFx3 windows feature installation on Windows 8.1
- Fixed problem with missing '\items\portal\properties.json' file
- Use path relative to 'install_dir' path for server and portal software authorization tools on linux
- Improved 'desktop' and 'licensemanager' recipes
- Supported domain user accounts

1.1.1
-----
- Initial release of arcgis cookbook 