arcgis-desktop cookbook
===============

This cookbook installs and configures ArcGIS Desktop and ArcGIS License Manager.

Requirements
------------

### Supported ArcGIS software

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
   
* ArcGIS License Manager
   * 2018.0
   * 2018.1
   * 2019.0
   * 2019.1
   * 2019.2
   * 2020.0
   * 2020.1

### Platforms

* Windows 10
* Windows Server 2012 (R2)
* Windows Server 2016
* Windows Server 2019
* Ubuntu 16.04, 18.04
* Rhel 6.5, 7.0

ArcGIS Desktop is supported only on Windows platforms.

### Dependencies
The following cookbooks are required:

* windows
* arcgis-repository

Attributes
----------

* `node['arcgis']['version']` = ArcGIS Desktop version. Default value is `10.8.1`.
* `node['arcgis']['desktop']['setup_archive']` = The location of ArcGIS Desktop setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['desktop']['setup']` = The location of ArcGIS Desktop setup executable. Default location is `%USERPROFILE%\Documents\ArcGIS10.8.1\Desktop\Setup.exe`.
* `node['arcgis']['desktop']['lp-setup']` = The location of language pack for ArcGIS Desktop. Default location is `C:\ArcGIS\DesktopLP\SetupFiles\setup.msi`.
* `node['arcgis']['desktop']['install_dir']` = ArcGIS Desktop installation directory. By default, ArcGIS Desktop is installed to `%ProgramFiles(x86)%\ArcGIS`.
* `node['arcgis']['desktop']['install_features']` = Comma-separated list of ArcGIS Desktop features to install. Default value is `ALL`.
* `node['arcgis']['desktop']['authorization_file']` = ArcGIS Desktop authorization file path. Default location and file name are `C:\\Temp\\license.prvc`.
* `node['arcgis']['desktop']['authorization_file_version']` = ArcGIS Desktop authorization file version. Default value is `10.8`.
* `node['arcgis']['desktop']['esri_license_host']` = Hostname of ArcGIS License Manager. Default hostname is `%COMPUTERNAME%`.
* `node['arcgis']['desktop']['software_class']` = ArcGIS Desktop software class <Viewer|Editor|Professional>. Default value is `Viewer`.
* `node['arcgis']['desktop']['seat_preference']` = ArcGIS Desktop license seat preference <Fixed|Float>. Default value is `Fixed`.
* `node['arcgis']['licensemanager']['version']` = ArcGIS License Manager version. Default value is `2020.1`.
* `node['arcgis']['licensemanager']['setup_archive']` = The location of ArcGIS License Manager setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['licensemanager']['setup']` = The location of ArcGIS License Manager setup executable. Default location is `%USERPROFILE%\Documents\ArcGIS License Manager 2020.1\LicenseManager\Setup.exe` on Windows, and `/opt/arcgis/2020.1/LicenseManager_Linux/Setup` on Linux.
* `node['arcgis']['licensemanager']['lp-setup']` = The location of language pack for ArcGIS License Manager. Default location is `C:\ArcGIS\LicenseManager\SetupFiles\setup.msi`.
* `node['arcgis']['licensemanager']['install_dir']` = ArcGIS License Manager installation directory. By default, the license manager is installed to `%ProgramFiles(x86)%\ArcGIS` on Windows and `/` on Linux.

Recipes
-------
### arcgis-desktop::default
Installs and configures ArcGIS Desktop.

### arcgis-desktop::licensemanager
Installs and configures ArcGIS License Manager.

### arcgis-desktop::lp-install
Installs language packs for ArcGIS Desktop and ArcGIS License Manager.

### arcgis-desktop::uninstall
Uninstalls ArcGIS Desktop and ArcGIS License Manager.

Usage
-----
See [wiki](https://github.com/Esri/arcgis-cookbook/wiki) pages for more information about using ArcGIS cookbooks.

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an [issue](https://github.com/Esri/arcgis-cookbook/issues).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

Licensing
---------

Copyright 2021 Esri

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

[](Esri Tags: ArcGIS Desktop Chef Cookbook)
[](Esri Language: Ruby)
