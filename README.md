[![Gitter chat](https://badges.gitter.im/gitterHQ/services.png)](https://gitter.im/arcgis-cookbook/Lobby)

# Chef Cookbooks for ArcGIS

This repository contains ArcGIS Chef cookbooks used to help simplify and automate ArcGIS installation and configuration using IT automation tool [Chef](https://www.chef.io/chef/). 

Included cookbooks:

* [arcgis-license-manager](cookbooks/arcgis-license-manager) - installs and configures ArcGIS License Manager.
* [arcgis-egdb](cookbooks/arcgis-egdb) - creates enterprise geodatabases in SQL Server or PostgreSQL DBMS and registers them with ArcGIS Server.
* [arcgis-enterprise](cookbooks/arcgis-enterprise) - installs and configures ArcGIS Server, ArcGIS Data Store, Portal for ArcGIS, ArcGIS WebAdaptor.
* [arcgis-geoevent](cookbooks/arcgis-geoevent) - installs and configures ArcGIS GeoEvent Server.
* [arcgis-insights](cookbooks/arcgis-insights) - installs and configures Insights for ArcGIS.
* [arcgis-mission](cookbooks/arcgis-mission) - installs and configures ArcGIS Mission Server.
* [arcgis-notebooks](cookbooks/arcgis-notebooks) - installs and configures ArcGIS Notebook Server.
* [arcgis-pro](cookbooks/arcgis-pro) - installs and configures ArcGIS Pro.
* [arcgis-repository](cookbooks/arcgis-repository) - downloads ArcGIS software setups from remote to local repositories.
* [arcgis-workflow-manager](cookbooks/arcgis-workflow-manager) - installs and configures ArcGIS Workflow Manager Server.
* [arcgis-video](cookbooks/arcgis-video) - installs and configures ArcGIS Video Server.
* [esri-iis](cookbooks/esri-iis) - enables IIS features required by ArcGIS Web Adaptor (IIS) and configures HTTPS binding.
* [esri-tomcat](cookbooks/esri-tomcat) - installs and configures Apache Tomcat for using with ArcGIS Web Adaptor.

Included ArcGIS deployment templates:

* [arcgis-datastore](templates/arcgis-datastore) - deploys different [ArcGIS Data Store types](https://enterprise.arcgis.com/en/portal/latest/administer/windows/what-is-arcgis-data-store.htm) and registers them with ArcGIS Server.
* [arcgis-egdb](templates/arcgis-egdb) - creates [enterprise GeoDatabases](https://enterprise.arcgis.com/en/server/latest/manage-data/windows/enterprise-geodatabases-and-arcgis-enterprise.htm) and registers them with ArcGIS Server.
* [arcgis-enterprise-base](templates/arcgis-enterprise-base) - deploys [base ArcGIS Enterprise](https://enterprise.arcgis.com/en/get-started/latest/windows/base-arcgis-enterprise-deployment.htm).
* [arcgis-geoevent](templates/arcgis-geoevent-server) - deploys [ArcGIS GeoEvent Server](https://enterprise.arcgis.com/en/geoevent/).
* [arcgis-license-manager](templates/arcgis-license-manager) - deploys [ArcGIS License Manager](https://desktop.arcgis.com/en/license-manager/latest/welcome.htm).
* [arcgis-mission-server](templates/arcgis-mission-server) - deploys [ArcGIS Mission Server](https://enterprise.arcgis.com/en/mission/) and federates it with  Portal for ArcGIS.
* [arcgis-notebook-server](templates/arcgis-notebook-server) - deploys [ArcGIS Notebook Server](https://enterprise.arcgis.com/en/notebook/) with an ArcGIS Enterprise deployment.
* [arcgis-portal](templates/arcgis-portal) - deploys [Portal for ArcGIS](https://enterprise.arcgis.com/en/portal/).
* [arcgis-pro](templates/arcgis-pro) - deploys [ArcGIS Pro](https://www.esri.com/en-us/arcgis/products/arcgis-pro/overview).
* [arcgis-server](templates/arcgis-server) - deploys ArcGIS Server in GIS Server, ArcGIS GeoAnalytics Server, Raster Analytics Server, Image Server, or Knowledge Server roles and federates it with Portal for ArcGIS.
* [arcgis-webadaptor](templates/arcgis-webadaptor) - deploys [ArcGIS Web Adaptor](https://enterprise.arcgis.com/en/server/latest/install/windows/about-the-arcgis-web-adaptor.htm).
* [arcgis-workflow-manager](templates/arcgis-workflow-manager) - deploys [ArcGIS Workflow Manager Server](https://enterprise.arcgis.com/en/workflow/).
* [arcgis-video-server](templates/arcgis-video-server) - deploys [ArcGIS Video Server](https://enterprise.arcgis.com/en/video/).

See [wiki](https://github.com/Esri/arcgis-cookbook/wiki) pages and cookbooks' README.md files for more information about using ArcGIS cookbooks.

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an [issue](https://github.com/Esri/arcgis-cookbook/issues).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

## Licensing

Copyright 2015-2024 Esri

Licensed under the Apache License, Version 2.0 (the "License");
You may not use this file except in compliance with the License.
You may obtain a copy of the License at
   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the license is available in the repository's [License.txt](https://github.com/Esri/arcgis-cookbook/blob/master/License.txt?raw=true) file.
