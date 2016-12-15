arcgis-server cookbook CHANGELOG
================================

This file is used to list changes made in each version of the arcgis-server cookbook.

2.3.1
-----
- Support creating EGDBs in Amazon RDS DB instances.
- Honor is_hosting attribute in enable_geoanalytics recipe.
- Support changing ArcGIS Server machine admnin URL.
- Support using join-site tool to add machine to ArcGIS Server site and the default cluster.
- Support configuring Portal for ArcGIS content store in Amazon S3.
- Keep ArcGIS Server log files on the local machines instead of using shared directories.
- Added max_log_file_age attribute to configure ArcGIS Server logs retention period.
 

2.3.0
-----
- Initial release of arcgis-server cookbook. arcgis 2.2.1 cookbook was split into arcgis-server, arcgis-desktop, arcgis-geoevent, and arcgis-pro cookbooks.

** New features in arcgis-server 2.3.0 cookbook, comparing to arcgis 2.2.1 cookbook:**

- Support for ArcGIS 10.5
- Support for Windows 10
- Support for upgrades (ArcGIS 10.4->10.4.1->10.5) on Windows
- Installing on Linux machines with pre-installed java application servers
- Support for running some recipes on Linux without root access
- Publishing services to ArcGIS Server
- Support for latest chef-client (12.*)versions.
- Added support for language packs installation.
