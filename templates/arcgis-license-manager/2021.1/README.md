---
layout: default
title: "arcgis-license-manager template"
category: templates
item: arcgis-license-manager
version: "2021.1"
latest: true
---

# arcgis-license-manager Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for ArcGIS License Manager machine roles.

## System Requirements

Consult the ArcGIS License Manager 2021.1 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client versions

* Chef Client 16, or
* Cinc Client 16

### Recommended ArcGIS Chef Cookbooks versions

* 3.8.0

### Supported Platforms

* Windows
  * Windows Server 2016 Standard and Datacenter
  * Windows Server 2019 Standard and Datacenter
  * Windows Server 2022 Standard and Datacenter  
  * Windows 10 Pro
* Linux
  * Red Hat Enterprise Linux Server 7
  * Red Hat Enterprise Linux Server 8

For Linux deployments, enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory:

Windows

* ArcGIS_License_Manager_Windows_2021_1_180127.exe

Linux

* ArcGIS_License_Manager_Linux_2021_1_180145.tar.gz

> The ArcGIS software repository directory is specified by the arcgis.repository.archives attribute. By default, it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run Chef client.

> Ensure that the directory specified by the arcgis.repository.setups attribute has enough space for setups extracted from the setup archives.

## Initial Deployment Workflow

The following is the recommended initial deployment workflow for the template machine roles:

1. Install [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run the Chef client on the machines as administrator/superuser using the JSON files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options, see the list of supported attributes described in the arcgis-enterprise cookbook README file.

### License Manager Machine

```shell
chef-client -z -j arcgis-license-manager-install.json
```

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

### arcgis-license-manager-install

Installs ArcGIS License Manager.

Required attribute changes:

* arcgis.run_as_user - (Linux) user account used to run the setup
