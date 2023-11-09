---
layout: default
title: "arcgis-desktop cookbook"
category: cookbooks
item: arcgis-desktop
version: 4.2.0
latest: true
---

# arcgis-desktop cookbook

This cookbook installs and configures ArcGIS Desktop and ArcGIS License Manager.

## Supported ArcGIS software

* ArcGIS Desktop (Windows only)
   * 10.4
   * 10.4.1
   * 10.5
   * 10.5.1
   * 10.6
   * 10.6.1
   * 10.7
   * 10.7.1
   * 10.8
   * 10.8.1
   * 10.8.2
   
* ArcGIS License Manager
   * 2018.0
   * 2018.1
   * 2019.0
   * 2019.1
   * 2019.2
   * 2020.0
   * 2020.1
   * 2021.0
   * 2021.1
   * 2022.0
   * 2022.1
   * 2023.0

## Platforms

* Windows 10
* Windows Server 2012 (R2)
* Windows Server 2016
* Windows Server 2019
* Windows Server 2022
* Ubuntu 16.04, 18.04
* Rhel 6.5, 7.0

ArcGIS Desktop is supported only on Windows platforms.

## Dependencies

The following cookbooks are required:

* windows
* arcgis-repository

## Attributes

* `node['arcgis']['version']` = ArcGIS Desktop version. Default value is `10.8.1`.
* `node['arcgis']['desktop']['setup_archive']` = The location of ArcGIS Desktop setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['desktop']['setup']` = The location of ArcGIS Desktop setup executable. Default location is `%USERPROFILE%\Documents\ArcGIS10.8.1\Desktop\Setup.exe`.
* `node['arcgis']['desktop']['lp-setup']` = The location of language pack for ArcGIS Desktop. Default location is `C:\ArcGIS\DesktopLP\SetupFiles\setup.msi`.
* `node['arcgis']['desktop']['install_dir']` = ArcGIS Desktop installation directory. By default, ArcGIS Desktop is installed to `%ProgramFiles(x86)%\ArcGIS`.
* `node['arcgis']['desktop']['install_features']` = Comma-separated list of ArcGIS Desktop features to install. Default value is `ALL`.
* `node['arcgis']['desktop']['authorization_file']` = ArcGIS Desktop authorization file path. Default location and file name are `C:\\Temp\\license.prvc`.
* `node['arcgis']['desktop']['authorization_file_version']` = ArcGIS Desktop authorization file version. Default value is `10.8`.
* `node['arcgis']['desktop']['esri_license_host']` = Hostname of ArcGIS License Manager. Default hostname is `%COMPUTERNAME%`.
* `node['arcgis']['desktop']['software_class']` = ArcGIS Desktop software class `<Viewer|Editor|Professional>`. Default value is `Viewer`.
* `node['arcgis']['desktop']['seat_preference']` = ArcGIS Desktop license seat preference `<Fixed|Float>`. Default value is `Fixed`.
* `node['arcgis']['licensemanager']['version']` = ArcGIS License Manager version. Default value is `2023.0`.
* `node['arcgis']['licensemanager']['setup_archive']` = The location of ArcGIS License Manager setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['licensemanager']['setup']` = The location of ArcGIS License Manager setup executable. Default location is `%USERPROFILE%\Documents\ArcGIS License Manager 2022.1\LicenseManager\Setup.exe` on Windows, and `/opt/arcgis/2022.1/LicenseManager_Linux/Setup` on Linux.
* `node['arcgis']['licensemanager']['lp-setup']` = The location of language pack for ArcGIS License Manager. Default location is `C:\ArcGIS\LicenseManager\SetupFiles\setup.msi`.
* `node['arcgis']['licensemanager']['install_dir']` = ArcGIS License Manager installation directory. By default, the license manager is installed to `%ProgramFiles(x86)%\ArcGIS` on Windows and `/` on Linux.

## Recipes

### default

Installs and configures ArcGIS Desktop.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "10.8.2",
    "desktop": {
      "setup": "C:\\ArcGIS\\10.8.2\\Desktop\\Setup.exe",
      "install_dir": "C:\\Program Files (x86)\\ArcGIS",
      "authorization_file": "C:\\ArcGIS\\10.8\\Authorization_Files\\DTBasic.prvc",
      "authorization_file_version": "10.8",
      "install_features": "ALL",
      "software_class": "Viewer",
      "seat_preference": "Fixed",
      "desktop_config": true,
      "modifyflexdacl": false
    },
    "python": {
      "install_dir": "C:\\Python27"
    }
  },
  "run_list":[
    "recipe[arcgis-desktop]"
  ]
}
```

> Software authorization for ArcGIS Desktop is only supported by the cookbook when the "seat_preference" attribute value is "Fixed".

> Chef cookbook [ms_dotnet](https://supermarket.chef.io/cookbooks/ms_dotnet/) could be used to install the .Net Framework version required by ArcGIS for Desktop. 

For example:

```JSON
{
  "ms_dotnet" : {
    "v4" : {
      "version" : "4.5.1"
    }
  },
  "run_list":[
    "recipe[ms_dotnet::ms_dotnet4]"
  ]
}
```

### licensemanager

Installs and configures ArcGIS License Manager.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "run_as_user": "arcgis",
    "repository": {
       "archives": "C:\\Software\\Esri",
       "setups": "C:\\Software\\Setups" 
    },
    "licensemanager": {
      "version": "2023.0",
      "setup": "C:\\Software\\Setups\\License Manager 2023.0\\LicenseManager\\Setup.exe",
      "install_dir": "C:\\Program Files (x86)\\ArcGIS"
    }
  },
  "run_list":[
    "recipe[arcgis-desktop::licensemanager]"
  ]
}
```

:grey_exclamation: run_as_user attribute is ignored on Windows.

### lp-install

Installs and configures language packs for ArcGIS Desktop and ArcGIS License Manager.

Attributes used by the recipe:
```JSON
{
  "arcgis": {
    "version": "10.8.2",
    "desktop": {
      "lp-setup": "C:\\ArcGIS\\10.8.2\\Desktop\\Japanese\\Setup.exe"
    },
    "licensemanager": {
      "lp-setup": "C:\\ArcGIS\\10.8.2\\LicenseManager\\Japanese\\Setup.exe"
    }
  },
  "run_list":[
    "recipe[arcgis-desktop::lp-install]"
  ]
}
```

:exclamation: Currently lp-install recipe is supported on Windows only.

### uninstall

Uninstalls ArcGIS Desktop and ArcGIS License Manager of the specified ArcGIS version.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "10.8.2",
    "run_as_user": "arcgis",
    "desktop": {
      "install_dir": "C:\\Program Files (x86)\\ArcGIS"
    },
    "licensemanager": {
      "install_dir": "C:\\Program Files (x86)\\ArcGIS"
    }
  },
  "run_list":[
    "recipe[arcgis-desktop::uninstall]"
  ]
}
```

> The arcgis.run_as_user attribute is ignored on Windows.
