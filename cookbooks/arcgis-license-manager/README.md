---
layout: default
title: "arcgis-license-manager cookbook"
category: cookbooks
item: arcgis-license-manager
version: 5.1.0
latest: true
---

# arcgis-license-manager cookbook

This cookbook installs and configures ArcGIS License Manager.

## Supported Versions

* 2021.1
* 2022.0
* 2022.1
* 2023.0
* 2024.0
* 2024.1

## Supported Platforms

* Windows Server 2022 Standard and Datacenter
* Windows Server 2019 Standard and Datacenter
* Windows Server 2016 Standard and Datacenter
* Windows 11 Pro and Enterprise (64 bit)
* Windows 10 Pro and Enterprise (64 bit)
* Red Hat Enterprise Linux (RHEL) Server 9
* Red Hat Enterprise Linux (RHEL) Server 8
* SUSE Linux Enterprise Server (SLES) 15

## Dependencies

The following cookbooks are required:

* arcgis-repository

## Attributes

* `node['arcgis']['run_as_user']` = User account used to run ArcGIS License Manager on Linux. Default account name is `arcgis`.
* `node['arcgis']['licensemanager']['version']` = ArcGIS License Manager version. Default value is `2024.1`.
* `node['arcgis']['licensemanager']['setup_archive']` = The location of ArcGIS License Manager setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['licensemanager']['setup']` = The location of ArcGIS License Manager setup executable. Default location is `%USERPROFILE%\Documents\ArcGIS License Manager 2024.1\LicenseManager\Setup.exe` on Windows, and `/opt/arcgis/2024.1/LicenseManager_Linux/Setup` on Linux.
* `node['arcgis']['licensemanager']['install_dir']` = ArcGIS License Manager installation directory. By default, the license manager is installed to `%ProgramFiles(x86)%\ArcGIS` on Windows and `/` on Linux.
* `node['arcgis']['licensemanager']['packages']` = Linux system packages to install before installing ArcGIS License Manager. Default value is `[]`.

## Recipes

### default

Calls arcgis-license-manager::licensemanager recipe.

### licensemanager

Installs and configures ArcGIS License Manager.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "repository": {
       "archives": "C:\\Software\\Esri",
       "setups": "C:\\Software\\Setups" 
    },
    "licensemanager": {
      "version": "2024.1",
      "setup": "C:\\Software\\Setups\\License Manager 2024.1\\LicenseManager\\Setup.exe",
      "install_dir": "C:\\Program Files (x86)\\ArcGIS"
    }
  },
  "run_list":[
    "recipe[arcgis-license-manager::licensemanager]"
  ]
}
```

## uninstall

Uninstalls ArcGIS License Manager.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "licensemanager": {
      "install_dir": "C:\\Program Files (x86)\\ArcGIS"
    }
  },
  "run_list":[
    "recipe[arcgis-license-manager::uninstall]"
  ]
}
```
