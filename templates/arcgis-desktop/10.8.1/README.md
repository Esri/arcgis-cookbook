# arcgis-desktop Deployment Template

Installs ArcGIS Desktop. 

## System Requirements

Consult the ArcGIS Desktop 10.8.1 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client versions

* Chef Client 15, or
* Cinc Client 15

### Recommended ArcGIS Chef Cookbooks versions

* 3.8.0

### Supported Platforms

* Windows
  * Windows 10 
  * Windows 10 Pro

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory:

* ArcGIS_Desktop_1081_175110.exe

> ArcGIS software repository directory is specified by arcgis.repository.archives attribute. By default it is set to local directory C:\Software\Archives. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run Chef client.

> Ensure that the directory specified by arcgis.repository.setups attribute has enough space for the setups extracted from the setup archives.

## Initial Deployment Workflow

The recommended initial deployment workflow for the template machine roles:

1. Install [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run Chef client on machines as administrator using the json files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options see the list of supported attributes described in arcgis-desktop cookbook README file.

### Concurrent Use ArcGIS Desktop

```shell
chef-client -z -j arcgis-desktop-concurrent-use.json
```

### Single Use ArcGIS Desktop

```shell
chef-client -z -j arcgis-desktop-single-use.json
```

## Upgrade Workflow

> It's not recommended to use the templates for upgrades if the sites were not initially deployed using the templates.

This is the first release of arcgis-desktop deployment template. The recommended upgrade workflow for this template will be provided in the subsequent releases.

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

### arcgis-desktop-concurrent-use

Installs ArcGIS Desktop and configures it with an existing ArcGIS License Manager.

> The concurrent use license must be either already authorized via License Manager or needs to be done manually.

Required attributes changes:

* arcgis.desktop.esri_license_host - ArcGIS License Server host name

### arcgis-desktop-single-use

Installs ArcGIS Desktop with single use license.

Required attributes changes:

* arcgis.desktop.authorization_file - ArcGIS Desktop authorization file path
