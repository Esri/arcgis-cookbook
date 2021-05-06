[![Gitter chat](https://badges.gitter.im/gitterHQ/services.png)](https://gitter.im/arcgis-cookbook/Lobby)

Chef Cookbooks for ArcGIS
=========================

This repository contains ArcGIS Chef cookbooks used to help simplify and automate ArcGIS installation and configuration using IT automation tool [Chef](https://www.chef.io/chef/). 

Included cookbooks:

* [arcgis-enterprise](cookbooks/arcgis-enterprise) - installs and configures ArcGIS Server, ArcGIS Data Store, Portal for ArcGIS, ArcGIS WebAdaptor
* [arcgis-geoevent](cookbooks/arcgis-geoevent) - installs and configures ArcGIS GeoEvent Server
* [arcgis-notebooks](cookbooks/arcgis-notebooks) - installs and configures ArcGIS Notebook Server
* [arcgis-mission](cookbooks/arcgis-mission) - installs and configures ArcGIS Mission Server
* [arcgis-insights](cookbooks/arcgis-insights) - installs and configures Insights for ArcGIS
* [arcgis-desktop](cookbooks/arcgis-desktop) - installs and configures ArcGIS Desktop
* [arcgis-pro](cookbooks/arcgis-pro) - installs and configures ArcGIS Pro
* [arcgis-repository](cookbooks/arcgis-repository) - downloads ArcGIS software setups from remote to local repositories
* [arcgis-egdb](cookbooks/arcgis-egdb) - creates enterprise geodatabases in SQL Server or PostgreSQL DBMS and registers them with ArcGIS Server
* [esri-tomcat](cookbooks/esri-tomcat) - installs and configures Apache Tomcat for using with ArcGIS Web Adaptor
* [esri-iis](cookbooks/esri-iis) - enables IIS features required by ArcGIS Web Adaptor (IIS) and configures HTTPS binding

Included ArcGIS deployment templates:

* [arcgis-datastore](templates/arcgis-datastore) -- Use this template to deploy and configure different [ArcGIS Data Store types](https://enterprise.arcgis.com/en/portal/latest/administer/windows/what-is-arcgis-data-store.htm).
* [arcgis-egdb](templates/arcgis-egdb) -- Lets you to create [enterprise geodatabases](https://enterprise.arcgis.com/en/server/latest/manage-data/windows/enterprise-geodatabases-and-arcgis-enterprise.htm) and register them with an ArcGIS Server site.
* [arcgis-enterprise-base](templates/arcgis-enterprise-base) -- Creates a [base ArcGIS Enterprise deployment](https://enterprise.arcgis.com/en/get-started/latest/windows/base-arcgis-enterprise-deployment.htm). 
* [arcgis-geoevent](templates/arcgis-geoevent-server) -- Creates an [ArcGIS GeoEvent Server](https://enterprise.arcgis.com/en/geoevent/) deployment.
* [arcgis-mission-server](templates/arcgis-mission-server) -- Deploys [ArcGIS Mission Server](https://enterprise.arcgis.com/en/mission/) and federates it with an ArcGIS Enterprise deployment.
* [arcgis-notebook-server](templates/arcgis-notebook-server) -- Deploys [ArcGIS Notebook Server](https://enterprise.arcgis.com/en/notebook/) with an ArcGIS Enterprise deployment.
* [arcgis-portal](templates/arcgis-portal) -- Deploys [Portal for ArcGIS](https://enterprise.arcgis.com/en/portal/).
* [arcgis-server](templates/arcgis-server) -- Creates any of the following ArcGIS Server sites and federates them with an ArcGIS Enterprise deployment: GIS Server, ArcGIS GeoAnalytics Server, Raster Analytics Server, Image Server.

See [wiki](https://github.com/Esri/arcgis-cookbook/wiki) pages and cookbooks' README.md files for more information about using ArcGIS cookbooks.

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an [issue](https://github.com/Esri/arcgis-cookbook/issues).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

Licensing
---------

Copyright 2020 Esri

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
