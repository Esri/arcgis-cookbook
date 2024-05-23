---
layout: default
title: "arcgis-pro cookbook"
category: cookbooks
item: arcgis-pro
version: 5.0.0
latest: true
---

# arcgis-pro Cookbook

This cookbook installs and configures ArcGIS Pro.

## Supported ArcGIS Pro versions

* 2.9
* 3.0
* 3.0.3
* 3.1
* 3.2
* 3.3

## Platforms

* Windows 10
* Windows 11
* Windows Server 2016
* Windows Server 2019
* Windows Server 2022

## Dependencies

The following cookbooks are required:

* windows
* arcgis-repository

## Attributes

* `node['arcgis']['pro']['version']` = ArcGIS Pro version. Default version is `3.3`
* `node['arcgis']['pro']['setup_archive']` = Path to ArcGIS Pro setup archive. Default value depends on the `node['arcgis']['pro']['version']` attribute value.
* `node['arcgis']['pro']['setup']` = The location of the ArcGIS Pro setup msi. Default location is `C:\Temp\ArcGISPro\ArcGISPro.msi`.
* `node['arcgis']['pro']['install_dir']` = ArcGIS Pro installation directory. Default installation directory is `%ProgramFiles%\ArcGIS\Pro`.
* `node['arcgis']['pro']['blockaddins']` = Configures the types of add-ins that ArcGIS Pro will load. Default value is `'0'`.
* `node['arcgis']['pro']['portal_list']` = ArcGIS Portal URLs. Default value is `https://www.arcgis.com/`.
* `node['arcgis']['pro']['allusers']` = Defines the installation context of ArcGIS Pro (1 - per machine, 2 - per user). Default value is '1'.
* `node['arcgis']['pro']['software_class']` = ArcGIS Pro software class `<Viewer|Editor|Professional>`. Default value is `Viewer`.
* `node['arcgis']['pro']['authorization_type']` = ArcGIS Pro authorization_type `<SINGLE_USE | CONCURRENT_USE | NAMED_USER>`. Default value is `NAMED_USER`.
* `node['arcgis']['pro']['esri_license_host']` = Host name of ArcGIS License Manager. Default host name is `%COMPUTERNAME%`.
* `node['arcgis']['pro']['authorization_file']` = ArcGIS Pro authorization file path.
* `node['arcgis']['pro']['authorization_file_version']` = ArcGIS Pro authorization file version. Default version is `11.3`.
* `node['arcgis']['pro']['lock_auth_settings']` = During a silent, per-machine installation of ArcGIS Pro, if the authorization type is defined, this attribute is set to true under HKEY_LOCAL_MACHINE\SOFTWARE\Esri\ArcGISPro\Licensing. When the lock_auth_settings attribute is set to true, the licensing settings in the registry apply to all ArcGIS Pro users on that machine; an individual user cannot make changes. To allow ArcGIS Pro users on the machine to define their own authorization settings through the ArcGIS Pro application, set lock_auth_settings to false. This property does not apply to a per-user installation. The default value is `false`.
* `node['arcgis']['repository']['archives']` = Path to the folder with the ArcGIS Pro software setup archives. Default path is `%USERPROFILE%\Software\Esri`.
* `node['arcgis']['repository']['patches']` = Path to the folder with hot fixes and patches for ArcGIS Pro software. The default path is `%USERPROFILE%\Software\Esri\Patches`.
* `node['arcgis']['patches']['local_patch_folder']` = Path to a local folder with hot fixes and patches for ArcGIS Pro software. The default path is `%USERPROFILE%\Software\Esri\Patches`.
* `node['ms_dotnet']['version']` = Microsoft .NET Framework version. The default version is `8.0.3`.
* `node['ms_dotnet']['setup']` = Microsoft .NET Framework setup path. The default path is `%USERPROFILE%\Software\Esri\windowsdesktop-runtime-8.0.3-win-x64.exe`.
* `node['ms_dotnet']['url']` = Microsoft .NET Framework setup URL. The default URL is `https://download.visualstudio.microsoft.com/download/pr/51bc18ac-0594-412d-bd63-18ece4c91ac4/90b47b97c3bfe40a833791b166697e67/windowsdesktop-runtime-8.0.3-win-x64.exe`.
* `node['webview2']['setup']` = Microsoft Edge WebView2 setup path. The default path is `%USERPROFILE%\Software\Esri\MicrosoftEdgeWebview2Setup.exe`.
* `node['webview2']['url']` = Microsoft Edge WebView2 setup URL. The default URL is `https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/4af8eb86-208b-4fb7-952b-af2a783d5c14/MicrosoftEdgeWebview2Setup.exe`.

## Recipes

### default

Installs and authorizes ArcGIS Pro.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "pro": {
      "version": "3.3",
      "authorization_file_version": "11.3",
      "setup": "C:\\ArcGIS\\ArcGIS Pro 3.3\\ArcGISPro\\ArcGISPro.msi",
      "allusers": 1,
      "authorization_type": "SINGLE_USE",
      "software_class": "Professional",  
      "portal_list": "https://domain.com/portal",
      "authorization_file": "C:\\ArcGIS\\11.3\\Authorization_Files\\Pro.prvc"    
    }
  },
  "run_list": [
    "recipe[arcgis-pro]"
  ]
}
```

### install_pro

Installs ArcGIS Pro.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "pro": {
     "version": "3.3",
     "setup": "C:\\ArcGIS\\ArcGIS Pro 3.3\\ArcGISPro\\ArcGISPro.msi",
     "allusers": 1  
    }
  },
  "run_list": [
    "recipe[arcgis-pro::install_pro]"
  ]
}
```

### ms_dotnet

Installs Microsoft .Net Framework (may require a machine reboot after chef run completes).

Attributes used by the recipe:

```JSON
{
  "ms_dotnet": {
    "version": "8.0.3",
    "setup": "C:\\Software\\Archives\\windowsdesktop-runtime-8.0.3-win-x64.exe"
  },
  "run_list": [
    "recipe[arcgis-pro::ms_dotnet]"
  ]
}
```

### patches

Installs ArcGIS Pro patches.

```JSON
{
  "arcgis":{
    "patches" : {
       "local_patch_folder" : "C:\\ArcGIS\\Patches"
     }   
  },
  "run_list":[
    "recipe[arcgis-pro::patches]"
  ]
}
```

### uninstall

Uninstalls ArcGIS Pro of the specified version.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "pro": {
      "version": "3.3"
    }
  },
  "run_list":[
    "recipe[arcgis-pro::uninstall]"
  ]
}
```

## webview2

Installs Microsoft Edge WebView2.

Attributes used by the recipe:

```JSON
{
  "webview2": {
    "setup": "C:\\Software\\Archives\\MicrosoftEdgeWebview2Setup.exe"
  },
  "run_list": [
    "recipe[arcgis-pro::webview2]"
  ]
}
```
