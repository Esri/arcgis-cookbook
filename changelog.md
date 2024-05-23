---
layout: default
title: "Changelog"
category: overview
item: changelog
latest: true
order: 6
---

# Changelog

Changes made in each version of the Chef Cookbooks for ArcGIS.

## 5.0.0

- Added support for ArcGIS Enterprise 11.3.
- Added support for ArcGIS Insights 2023.2 and 2023.3.
- Added support for ArcGIS License Manager 2024.0.
- Added support for ArcGIS Pro 3.3.
- Added arcgis-video cookbook.
- Added arcgis-license-manager cookbook.
- Removed arcgis-desktop cookbook.
- Dropped support for Chef 14.
- Updated third party cookbooks to latest versions.

## 4.2.0

- Added support for ArcGIS Enterprise 11.2.
- Added support for ArcGIS Pro 3.2.
- Added support for ArcGIS Insights 2023.1.
- Added support for ArcGIS License Manager 2023.0.

## 4.1.0

- Added support for ArcGIS Enterprise 11.1.
- Added support for ArcGIS Pro 3.0.3/3.1.
- Added support for ArcGIS Insights 2022.3.
- Added support for ArcGIS License Manager 2022.1.
- Improved handling of sensitive attributes.
- Added ability to define the UID and GID for arcgis user on linux systems.
  
## 4.0.0

- Added support for ArcGIS Enterprise 11.0.
- Added support for ArcGIS Pro 3.0.
- Added support for ArcGIS Insights ArcGIS 2022.1/2022.1.1/2022.2.
- Improved support for installing ArcGIS Enterprise patches.
- Added support for downloading ArcGIS setup archives from <https://downloads.arcgis.com>.

## 3.8.0

- Added support for ArcGIS Enterprise 10.9.1
  - Added unfederate_server recipe
- Added support for ArcGIS Mission Server 10.9.1
  - Added unregister_server_wa recipe
- Added support for ArcGIS Notebook Server 10.9.1
  - Added unregister_server_wa recipe
- Added support for ArcGIS GeoEvent 10.9.1
  - Added admin_reset recipe
- Added support for ArcGIS Pro 2.8 and 2.9
  - Added deployment templates for ArcGIS Pro 2.8 and 2.9
  - Added ms_dotnet recipe
- Added support for ArcGIS Desktop 10.8.2
  - Added deployment templates for ArcGIS Desktop 10.8.1 and 10.8.2
- Added support for ArcGIS License Manager 2021.0 and 2021.1
  - Added deployment templates for ArcGIS License Manager 2021.0 and 2021.1
- Added arcgis-workflow-manager cookbook and deployment template
  - arcgis-workflow-manager cookbook supports ArcGIS Workflow Manager Server 10.8.1, 10.9, and 10.9.1
  - arcgis-workflow-manager cookbook supports ArcGIS Workflow Manager Web App 10.8.1 and 10.9 (Note: 10.9.1 Web App is built into portal setup.)
- Added support for ArcGIS Insights 2021.1, 2021.1.1, 2021.2, 2021.2.1, 2021.3, and 2021.3.1
- Added install recipe to esri-iis cookbook
- Added support for upgrades using the deployment templates
- Added new tool for copying attributes from one json config file to another

Fixed issues:

- [Template for ArcGIS Enterprise upgrade](https://github.com/Esri/arcgis-cookbook/issues/294_
- [unfederating recipe](https://github.com/Esri/arcgis-cookbook/issues/265)

## 3.7.0

- Added support for ArcGIS Enterprise 10.9
- Added ArcGIS Enterprise 10.9 deployment templates
- Added support for Windows Group Managed Service  Accounts (gMSA) for ArcGIS GeoEvent Server, ArcGIS Mission Server, and ArcGIS Notebook Server
- Added iptables, firewalld, and openjdk recipes to esri-tomcat cookbook
- Added support for Cinc Client 15

Fixed issues:

- [Unable to install raster analytics role - fails with reason "the server does not have a raster data store"](https://github.com/Esri/arcgis-cookbook/issues/276)
- [Configure Portal System properties to set Proxy](https://github.com/Esri/arcgis-cookbook/issues/273)
- [Failed to configure SSL certificates in ArcGIS Server. Importing CA certificate failed.](https://github.com/Esri/arcgis-cookbook/issues/272)
- [Recipe Patch Mixlib::ShellOut::CommandTimeout](https://github.com/Esri/arcgis-cookbook/issues/268)
- [recipe[arcgis-geoevent] cannot rerun](https://github.com/Esri/arcgis-cookbook/issues/263)
  
## 3.6.1

- Added support for Chef Client 15+
- Added unregister_machines recipe in arcgis-enterprise cookbook
- Added support ArcGIS Insights 2020.2 and 2020.3

Fixed issues:

- [NoMethodError while registering SDE files in ArcGIS Server 10.7.1](https://github.com/Esri/arcgis-cookbook/issues/244)
- [ArcGIS Datastore Backup directory in a HA deployment](https://github.com/Esri/arcgis-cookbook/issues/210)

## 3.6.0

- Added arcgis-mission cookbook and deployment templates (ArcGIS Mission Server 10.8 and 10.8.1)
- Added support for ArcGIS Enterprise 10.8.1
  - Added support for importing root SSL certificate into ArcGIS Server
  - Added option to configure ArcGIS Data Store mode (PrimaryStandby or Cluster)
  - Added recipe to unregister all ArcGIS Server Web Adaptors from a site (unregister_server_wa)
- Added support for Insights for ArcGIS 3.4/3.4.1/2020.1
- Added support for ArcGIS Pro 2.6
- Added support for ArcGIS Desktop 10.8.1 and ArcGIS License Manager 2020.0
  - Fixed software authorization issues with single use ArcGIS Desktop licenses

## 3.5.0

- Added support for ArcGIS 10.8
- Added arcgis-notebooks cookbook and deployment templates
- Added support for custom setup command line parameters
- Added support for using hostnames instead of IP addresses on AWS
- Added support for Windows Managed Service Accounts
- Added support for Password protected Esri Secured License Files (ESLF)

## 3.4.0

- Added support for ArcGIS 10.7.1 (Supports both 10.7 and 10.7.1)
- Added support for ArcGIS WebStyles
- Updated and locked versions of dependent cookbooks
- Removed arcgis-repository cookbook dependencies on aws cookbook to simplify use in disconnected environments

## 3.3.1

- Workaround for [BUG-000121142](https://support.esri.com/en/technical-article/000020633)
- Increased configuredatastore tool execution timeout to 3 hours.

## 3.3.0

- Added support for ArcGIS 10.7 
- Added support for Insights for ArcGIS 3.0/3.1
- Added support for ArcGIS Pro 2.3/2.4
- Dropped support for ArcGIS Enterprise versions prior to 10.7
- Added arcgis-repository and arcgis-egdb cookbooks
- All arcgis-* cookbooks now support local ArcGIS repository

## 3.2.1

- Support for ArcGIS Enterprise 10.6.1.
- Enabling raster analytics and image hosting server roles.
- Added install_datastore, install_portal_wa, install_portal, install_server_wa, and install_server recipes that just install the applications without configuring them.
- Added stop_machine, stop_server, and unregister_machine recipes.
- Use configurebackup location Data Store tool instead of deprecated changebackuplocation.
- Added portal_security recipe.
- Improved configuring preferred host identifiers for Portal and Data Store.
- Added datasources recipe to support registering data sources to ArcGIS Server.
- Added support for ArcGIS Pro 2.2.
- Added patches recipe for ArcGIS Pro 
- Added 3 installation modes for ArcGIS Pro : SINGLE_USE | CONCURRENT_USE | NAMED_USER
- Added ec2 test kitchen

## 3.2.0

- Support for ArcGIS Enterprise 10.6.
- Support for ArcGIS Pro 2.1.
- Support for Insights for ArcGIS 2.0/2.1.
- Support for Chef-Client 13.

## 3.1.0

- Support for ArcGIS 10.5.1.
- Added support for configuring ArcGIS Server identity stores and assigns privileges to roles.
- Added support for installing ArcGIS Enterprise patches.
- Set default values for sensitive attributes using environmental variables.
- Support setting of keystore type for HTTPS listener in esri-tomcat cookbook.

## 3.0.0

- 'iis' recipe moved to new 'esri-iis' cookbook.
- Supported Windows firewall configuration for ArcGIS Enterprise applications.
- Introduced local ArcGIS software repository.
- Supported extraction of ArcGIS software setups from archives to a local setup repository.
- Completed the ArcGIS Server 10.5 upgrade procedure.
- Added recipe to run user-defined post installation script.
- Added creation of network shares in 'fileserver' recipe.
- Supported setting log level in Portal for ArcGIS.
- arcgis-server cookbook renamed to arcgis-enterprise.
- Added arcgis-insights cookbook.

## 2.3.1

- added support for ArcGIS 10.5.
- Support creating EGDBs in Amazon RDS DB instances.
- Honor is_hosting attribute in enable_geoanalytics recipe.
- Support changing ArcGIS Server machine admin URL.
- Support using join-site tool to add machine to ArcGIS Server site and the default cluster.
- Support configuring Portal for ArcGIS content store in Amazon S3.
- Keep ArcGIS Server log files on the local machines instead of using shared directories.
- Added max_log_file_age attribute to configure ArcGIS Server logs retention period.
- Configure 'arcgisgeoevent' system.d service.

## 2.3.0

- 'arcgis' cookbook was split into arcgis-server, arcgis-desktop, arcgis-geoevent, and arcgis-pro cookbooks.
- Added esri-tomcat cookbook that wraps 'tomcat' cookbooks v2.
- Support for ArcGIS 10.5 Beta.
- Support for Windows 10.
- Support for upgrades (ArcGIS 10.4->10.4.1->10.5) on Windows
- Installing on Linux machines with pre-installed java application servers.
- Support for running some recipes on Linux without root access.
- Publishing services to ArcGIS Server.
- Support for latest chef-client (12.*) versions.
- Added support for language packs installation.
  
## 2.2.1

- Added support for ArcGIS 10.4.1.

## 2.2.0

- This release supports only ArcGIS 10.4 release software.
- Added 'all_uninstalled' and 'cleanup' recipes.
- Added 'arcgis' top level key to all arcgis cookbook attributes.
- Added support for ArcGIS Pro.
- Using 10.4 federation and HA workflows.
- Improved Data Store configuration.

## 1.1.3

- Added ArcGIS GeoEvent Extension for Server resource.
- Default value of attribute node['data_store']['preferredidentifier'] set to 'hostname' instead of 'ip'.

## 1.1.2

- Support configuration of highly available Portal for ArcGIS.
- Fixed problem with NetFx3 windows feature installation on Windows 8.1.
- Fixed problem with missing '\items\portal\properties.json' file.
- Use path relative to 'install_dir' path for server and portal software authorization tools on linux.
- Improved 'desktop' and 'licensemanager' recipes.
- Supported domain user accounts.

## 1.1.1

- First release of the cookbook.
