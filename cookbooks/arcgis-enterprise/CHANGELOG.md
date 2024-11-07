arcgis-enterprise cookbook CHANGELOG
================================

This file is used to list changes made in each version of the arcgis-enterprise cookbook.

5.1.0
-----
- Added support for ArcGIS Enterprise 11.4

5.0.0
-----
- Added support for ArcGIS Enterprise 11.3

4.2.0
-----
- Added support for ArcGIS Enterprise 11.2
- Added support for Rocky Linux and AlmaLinux platforms

4.1.0
-----
- Added support for ArcGIS Enterprise 11.1

4.0.0
-----
- Added support for ArcGIS Enterprise 11.0

3.8.0
-----
- Added support for ArcGIS Enterprise 10.9.1.

3.7.0
-----
- Added support for ArcGIS Enterprise 10.9.
- Added start_portal, stop_portal, start_datastore, and server_data_items recipes.
- Increased patch install timeout to 1 hour.
- Deprecated iptables recipe (use esri-tomcat::iptables instead).
- Added support for configurable lists of directories and file shares in fileserver recipe.
- Added support for setting Portal for ArcGIS system properties.
- Updated and locked versions of dependent cookbooks.

3.6.1
-----
- Added support for Chef Client 15.

3.6.0
-----
- Added support for ArcGIS Enterprise 10.8.1.
- Added support for importing root SSL certificate into ArcGIS Server.

3.5.0
-----
- Added support for ArcGIS Enterprise 10.8.
- Added support for custom setup command line parameters.
- Added support for using hostnames instead of IP addresses on AWS.
- Added support for Windows Managed Service Accounts.
- Added support for Password protected Esri Secured License Files (ESLF)

3.4.0
-----
- Added support for ArcGIS Enterprise 10.7.1.
- Updated and locked versions of depenent cookbooks.

3.3.0
-----
- Added support for ArcGIS Enterprise 10.7 and dropped support for previous ArcGIS Enterprise versions.
- Added dependency on new arcgis-repository cookbook to support global ArcGIS software repository in S3.
- Moved rds_egdb and sql_alias recipes to new arcgis-egdb cookbook.
- Added register_machine and unregister_stopped_machines recipes

3.2.1
-----
- Support for ArcGIS Enterprise 10.6.1.
- Enabling raster analytics and image hosting server roles.
- Added install_datastore, install_portal_wa, install_portal, install_server_wa, and install_server recipes that just install the applications without configuring them.
- Added stop_machine, stop_server, and unregister_machine recipes.
- Use configurebackup location Data Store tool instead of deprecated changebackuplocation.
- Added portal_security recipe.
- Improved configuring preferred host identifiers for Portal and Data Store.
- Added datasources recipe to support registering data sources to ArcGIS Server.

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

