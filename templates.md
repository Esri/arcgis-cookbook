---
layout: default
title: "About Deployment Templates"
category: overview
item: templates
latest: true
order: 4
---

# About Deployment Templates

Chef deployment templates for ArcGIS contain ready-to-use JSON files for ArcGIS machine roles specific to ArcGIS versions and platforms. The deployment templates provide a straightforward and deterministic way to automate initial deployments and upgrades of ArcGIS on-premises and in the cloud.

The deployment template JSON files can be used out-of-the-box with chef-solo or Chef Server. The Chef Server approach is preferred in large deployments, whereas the chef-solo approach is more favorable in single machine or smaller deployments.

Each template's README file describes specific workflows for initial setup, patching, and upgrade of ArcGIS deployments.

Available Chef deployment templates:

* [arcgis-datastore]({{ site.baseurl }}/templates/arcgis-datastore/11.4.html) - deploys different [ArcGIS Data Store types](https://enterprise.arcgis.com/en/portal/11.4/administer/windows/what-is-arcgis-data-store.htm) and registers them with ArcGIS Server.
* [arcgis-desktop]({{ site.baseurl }}/templates/arcgis-desktop/10.8.2.html) - deploys [ArcGIS Desktop](https://desktop.arcgis.com/en/).
* [arcgis-egdb]({{ site.baseurl }}/templates/arcgis-egdb/11.4.html) - creates [enterprise GeoDatabases](https://enterprise.arcgis.com/en/server/11.4/manage-data/windows/enterprise-geodatabases-and-arcgis-enterprise.htm) and registers them with ArcGIS Server.
* [arcgis-enterprise-base]({{ site.baseurl }}/templates/arcgis-enterprise-base/11.4.html) - deploys [base ArcGIS Enterprise](https://enterprise.arcgis.com/en/get-started/11.4/windows/base-arcgis-enterprise-deployment.htm).
* [arcgis-geoevent]({{ site.baseurl }}/templates/arcgis-geoevent-server/11.4.html) - deploys [ArcGIS GeoEvent Server](https://enterprise.arcgis.com/en/geoevent/).
* [arcgis-license-manager]({{ site.baseurl }}/templates/arcgis-license-manager/2024.1.html) - deploys [ArcGIS License Manager](https://desktop.arcgis.com/en/license-manager/latest/welcome.htm).
* [arcgis-mission-server]({{ site.baseurl }}/templates/arcgis-mission-server/11.4.html) - deploys [ArcGIS Mission Server](https://enterprise.arcgis.com/en/mission/) and federates it with  Portal for ArcGIS.
* [arcgis-notebook-server]({{ site.baseurl }}/templates/arcgis-notebook-server/11.4.html) - deploys [ArcGIS Notebook Server](https://enterprise.arcgis.com/en/notebook/) with an ArcGIS Enterprise deployment.
* [arcgis-portal]({{ site.baseurl }}/templates/arcgis-portal/11.4.html) - deploys [Portal for ArcGIS](https://enterprise.arcgis.com/en/portal/).
* [arcgis-pro]({{ site.baseurl }}/templates/arcgis-pro/3.4.html) - deploys [ArcGIS Pro](https://www.esri.com/en-us/arcgis/products/arcgis-pro/overview).
* [arcgis-server]({{ site.baseurl }}/templates/arcgis-server/11.4.html) - deploys ArcGIS Server in GIS Server, ArcGIS GeoAnalytics Server, Raster Analytics Server, Image Server, or Knowledge Server roles and federates it with Portal for ArcGIS.
* [arcgis-video-server]({{ site.baseurl }}/templates/arcgis-video-server/11.4.html) - deploys ArcGIS Video Server with an ArcGIS Enterprise deployment.
* [arcgis-webadaptor]({{ site.baseurl }}/templates/arcgis-webadaptor/11.4.html) - deploys [ArcGIS Web Adaptor](https://enterprise.arcgis.com/en/server/11.4/install/windows/about-the-arcgis-web-adaptor.htm).
* [arcgis-workflow-manager]({{ site.baseurl }}/templates/arcgis-workflow-manager/11.4.html) - deploys [ArcGIS Workflow Manager Server](https://enterprise.arcgis.com/en/workflow/).

 The deployment templates' source code is available in [GitHub](https://github.com/Esri/arcgis-cookbook). The GitHub repository's [releases](https://github.com/Esri/arcgis-cookbook/releases) section contains distribution archives that include the deployment templates along with all the cookbooks used by the templates.
