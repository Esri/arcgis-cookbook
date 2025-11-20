---
layout: default
title: "arcgis-insights cookbook"
category: cookbooks
item: arcgis-insights
version: 5.3.0
latest: true
---

# arcgis-insights cookbook

This cookbook installs and configures ArcGIS Insights.

## Supported ArcGIS Insights versions

* 2020.1
* 2020.2
* 2020.3
* 2021.1
* 2021.1.1
* 2021.2
* 2021.2.1
* 2021.3
* 2021.3.1
* 2022.1
* 2022.1.1
* 2022.2
* 2022.3
* 2023.1
* 2023.2
* 2023.3
* 2024.1
* 2024.2
* 2025.1

## Platforms

* Windows 11
* Windows Server 2016
* Windows Server 2019
* Windows Server 2022
* Windows Server 2025
* Ubuntu Server 20.04 LTS
* Ubuntu Server 22.04 LTS
* Ubuntu Server 24.04 LTS
* Red Hat Enterprise Linux Server 8
* Red Hat Enterprise Linux Server 9
* SUSE Linux Enterprise Server 15
* Oracle Linux 8
* Oracle Linux 9
* Rocky Linux 8
* Rocky Linux 9
* AlmaLinux 9

## Dependencies

The following cookbooks are required:

* arcgis-enterprise
* arcgis-repository

## Attributes

* `node['arcgis']['insights']['version']` = ArcGIS Insights version. Default version is `2025.1`
* `node['arcgis']['insights']['setup_archive']` = Path to the ArcGIS Insights setup archive. Default value depends on `node['arcgis']['insights']['version']` attribute value.
* `node['arcgis']['insights']['setup']` = The location of the ArcGIS Insights setup executable. Default location is `%USERPROFILE%\\Documents\\ArcGIS Insights 2025.1\\Insights\\Setup.exe` on Windows and `/opt/arcgis/Insights/Insights-Setup.sh` on Linux.
* `node['arcgis']['insights']['patches']` = File names of ArcGIS Insights patches to install. Default value is `[]`.

## Recipes

### default

Installs and configures ArcGIS Insights.

> ArcGIS Server or Portal for ArcGIS must be installed on the machine before running the arcgis-insights::default recipe.
> After ArcGIS Insights is installed, the ArcGIS Server or Portal for ArcGIS must be restarted.
> 
Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "12.0",
    "run_as_user": "arcgis",
    "run_as_password": "<password>",
    "portal": {
      "install_dir": "C:\\Program Files\\ArcGIS",
    },
    "insights": {
      "version": "2025.1",
      "setup": "%USERPROFILE%\\Documents\\ArcGIS Insights 2025.1\\Insights\\Setup.exe"
    }
  },
  "run_list": [
    "recipe[arcgis-insights]",
    "recipe[arcgis-enterprise::stop_portal]",
    "recipe[arcgis-enterprise::start_portal]"
  ]
}
```

### install_patches

Installs patches for ArcGIS Insights. The recipe installs patches from the patches folder specified by the arcgis.insights.patches attribute. The patch names may contain a wildcard '\*'. For example, "ArcGIS-120-\*.msp" specifies all .msp patches that start with "ArcGIS-120-".

Attributes used by the recipe:

```JSON
{
  "arcgis" : {
    "repository" : {
      "patches" : "%USERPROFILE%\\Software\\Esri\\patches"
    },
    "insights": {
      "patches": ["patch1.msp", "patch2.msp"]
    }
  },
  "run_list": [
    "recipe[arcgis-insights::install_patches]"
  ]
}
```

### uninstall

Uninstalls ArcGIS Insights.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "12.0",
    "run_as_user": "arcgis",
    "portal": {
      "install_dir": "C:\\Program Files (x86)\\ArcGIS"
    },
    "insights": {
      "version": "2025.1"
     }
  },
  "run_list":[
    "recipe[arcgis-insights::uninstall]",
    "recipe[arcgis-enterprise::stop_portal]",
    "recipe[arcgis-enterprise::start_portal]"
  ]
}
```
