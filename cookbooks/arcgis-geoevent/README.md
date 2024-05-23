---
layout: default
title: "arcgis-geoevent cookbook"
category: cookbooks
item: arcgis-geoevent
version: 5.0.0
latest: true
---

# arcgis-geoevent cookbook

This cookbook installs and configures ArcGIS GeoEvent Server.

## Supported ArcGIS versions

* 10.9.1
* 11.0
* 11.1
* 11.2
* 11.3

## Supported ArcGIS software

* ArcGIS GeoEvent Server

## Platforms

* Windows 8 (8.1)
* Windows 10
* Windows Server 2012 (R2)
* Windows Server 2016
* Windows Server 2019
* Windows Server 2022
* Ubuntu Server 20.04 LTS
* Ubuntu Server 22.04 LTS
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

* `node['arcgis']['geoevent']['authorization_file']` = ArcGIS GeoEvent Server authorization file path. 
* `node['arcgis']['geoevent']['authorization_file_version']` = ArcGIS GeoEvent Server authorization file version. Default value is `node['arcgis']['server']['authorization_file_version']`.
* `node['arcgis']['geoevent']['setup_archive']` = Path to the ArcGIS GeoEvent Server setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['geoevent']['setup']` = The location of the ArcGIS GeoEvent Server setup executable. Default location is `%USERPROFILE%\Documents\ArcGIS11.3\ArcGISGeoEventServer\Setup.exe` on Windows and `/opt/arcgis/11.3/geoevent/Setup.sh` on Linux.
* `node['arcgis']['geoevent']['setup_options']` = Additional ArcGIS GeoEvent Server setup command line options. Default options are `''`.
* `node['arcgis']['geoevent']['configure_autostart']` = If set to true, on Linux the GeoEvent Server is configured to start with the operating system.  Default value is `true`.
* `node['arcgis']['geoevent']['ports']` = Ports to open for GeoEvent. Default depends on `node['arcgis']['version']`.
* `node['arcgis']['geoevent']['patches]` = File names of ArcGIS GeoEvent Server patches to install. Default value is `[]`.

## Recipes

### admin_reset

Administratively resets GeoEvent Server.

> Deletes the Apache ZooKeeper files (to administratively clear the GeoEvent Server configuration), the product’s runtime files (to force the system framework to be rebuilt), and removes previously received event messages (by deleting Kafka topic queues from disk). This is how system administrators reset a GeoEvent Server instance to look like the product has just been installed.

> If you have custom components in the C:\Program Files\ArcGIS\Server\GeoEvent\deploy folder, move these from the \deploy folder to a local temporary folder, while GeoEvent Server is running, to prevent the component from being restored (from the distributed configuration store) when GeoEvent Server is restarted. Also, make sure you have a copy of the most recent XML export of your GeoEvent Server configuration if you want to save the elements you have created.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.3",
        "run_as_user": "arcgis",
        "server": {
            "install_dir": "C:\\Program Files\\ArcGIS\\Server"
        }
    },
    "run_list": [
        "recipe[arcgis-geoevent::admin_reset]"
    ]
}
```

### default

Installs and configures ArcGIS GeoEvent Server.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "run_as_user": "arcgis",
    "run_as_password": "<password>",
    "server": {
      "install_dir": "C:\\Program Files\\ArcGIS",
    },
    "geoevent": {
      "setup": "C:\\ArcGIS\\11.3\\GeoEvent\\Setup.exe",
      "authorization_file": "C:\\ArcGIS\\11.3\\Authorization_Files\\GeoEvent.prvc",
      "authorization_file_version": "11.3"
    }
  },
  "run_list": [
    "recipe[arcgis-geoevent]"
  ]
}
```

### install_patches

Installs patches for ArcGIS GeoEvent Server. The recipe installs patches from the patches folder specified by the arcgis.geoevent.patches attribute. The patch names may contain a wildcard '\*'. For example, "GeoEvent_10_9_1_*.msp" specifies all .msp patches that start with "GeoEvent_10_9_1_".

Attributes used by the recipe:

```JSON
{
  "arcgis" : {
    "repository" : {
      "patches" : "%USERPROFILE%\\Software\\Esri\\patches"
    },
    "geoevent": {
      "patches": ["patch1.msp", "patch2.msp"]
    }
  },
  "run_list": [
    "recipe[arcgis-geoevent::install_patches]"
  ]
}
```

### lp-install

Installs the language pack for ArcGIS GeoEvent Server.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "geoevent": {
      "lp-setup": "C:\\ArcGIS\\11.3\\GeoEvent\\Japanese\\Setup.exe"
    }
  },
  "run_list":[
    "recipe[arcgis-geoevent::lp-install]"
  ]
}
```

### uninstall

Uninstalls ArcGIS GeoEvent Server.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.3",
    "run_as_user": "arcgis",
    "server": {
      "install_dir": "C:\\Program Files\\ArcGIS"
    }
  },
  "run_list":[
    "recipe[arcgis-geoevent::uninstall]"
  ]
}
```

> The arcgis.run_as_user and install_dir attributes are ignored on Windows.
