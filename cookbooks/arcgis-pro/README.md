arcgis-pro Cookbook
===============

This cookbook installs and configures ArcGIS Pro.

Requirements
------------

### Supported ArcGIS Pro versions
* 1.2
* 1.3
* 1.4
* 2.0
* 2.1
* 2.2
* 2.3
* 2.4

### Platforms
* Windows 7
* Windows 8 (8.1)
* Windows 10
* Windows Server 2008 (R2)
* Windows Server 2012 (R2)
* Windows Server 2016
* Windows Server 2019

### Dependencies
The following cookbooks are required:
* windows
* arcgis-repository

Attributes
----------

* `node['arcgis']['pro']['version']` = ArcGIS Pro version. Default version is `2.3`
* `node['arcgis']['pro']['setup_archive']` = Path to ArcGIS Pro setup archive. Default value depends on `node['arcgis']['pro']['version']` attribute value.
* `node['arcgis']['pro']['setup']` = The location of ArcGIS Pro setup msi. Default location is `C:\Temp\ArcGISPro\ArcGISPro.msi`.
* `node['arcgis']['pro']['install_dir']` = ArcGIS Pro installation directory. Default installation directory is `%ProgramFiles%\ArcGIS\Pro`.
* `node['arcgis']['pro']['blockaddins']` = Configures the types of Add-ins that ArcGIS Pro will load. Default value is `'#0'`.
* `node['arcgis']['pro']['portal_list']` = ArcGIS Portal URLs. Default value is `https://www.arcgis.com/`.
* `node['arcgis']['pro']['allusers']` = Defines installation context of ArcGIS Pro, 1 - per machine and 2 - per user. Default value is '2'.
* `node['arcgis']['pro']['software_class']` = ArcGIS Pro software class <Viewer|Editor|Professional>. Default value is `Viewer`.
* `node['arcgis']['pro']['authorization_type']` = ArcGIS Pro authorization_type <SINGLE_USE | CONCURRENT_USE | NAMED_USER>. Default value is `NAMED_USER`.
* `node['arcgis']['pro']['esri_license_host']` = Hostname of ArcGIS License Manager. Default hostname is `%COMPUTERNAME%`.
* `node['arcgis']['pro']['authorization_file']` = ArcGIS Pro authorization file path.
* `node['arcgis']['repository']['archives']` = Path to folder with ArcGIS software setup archives. Default path is `%USERPROFILE%\Software\Esri`.
* `node['arcgis']['repository']['patches']` = Path to folder with hot fixes and patches for ArcGIS Pro software. The default path is `%USERPROFILE%\Software\Esri\Patches`.
* `node['arcgis']['patches']['local_patch_folder']` = Path to local folder with hot fixes and patches for ArcGIS Pro software. The default path is `%USERPROFILE%\Software\Esri\Patches`.

Recipes
-------

### arcgis-pro::default
Installs ArcGIS Pro.

### arcgis-pro::uninstall
Uninstalls ArcGIS Pro.

### arcgis-pro::patches
Installs ArcGIS Pro patches.

Usage
-----

See [wiki](https://github.com/Esri/arcgis-cookbook/wiki) pages for more information about using ArcGIS cookbooks.

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an [issue](https://github.com/Esri/arcgis-cookbook/issues).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

Licensing
---------

Copyright 2016 Esri

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

[](Esri Tags: ArcGIS Pro Chef Cookbook)
[](Esri Language: Ruby)
