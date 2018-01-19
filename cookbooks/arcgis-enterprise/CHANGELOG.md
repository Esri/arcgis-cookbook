arcgis-enterprise cookbook CHANGELOG
================================

This file is used to list changes made in each version of the arcgis-enterprise cookbook.

3.2.0
-----
- Support for ArcGIS Enterprise 10.6.
- Support for Chef-Client 13.
- Setting maximum heap size of ArcSOC processes.
- Support upgrade of ArcGIS Enterprise on Linux.

3.1.0
-----
- Added support for ArcGIS Enterprise 10.5.1.
- Added support for configuring ArcGIS Server identity stores and assigns privileges to roles.
- Added support for installing ArcGIS Enterprise patches.
- Set default values for sensitive attributes using environmental variables.

3.0.0
-----
- 'iis' recipe moved to new 'esri-iis' cookbook.
- Supported Windows firewall configuration for ArcGIS Enterprise applications.
- Introduced local ArcGIS software repository.
- Supported extraction of ArcGIS software setups from archives to a local setup repository.
- Completed the ArcGIS Server 10.5 upgrade procedure.
- Added recipe to run user-defined post installation script.
- Added creation of network shares in 'fileserver' recipe.
- Suppored setting log level in Portal for ArcGIS.
- arcgis-server cookbook renamed to arcgis-enterprise.

