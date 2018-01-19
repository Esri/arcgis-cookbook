arcgis-insights cookbook
===============

This cookbook installs and configures Insights for ArcGIS.

Requirements
------------

### Supported Insights for ArcGIS versions

* 1.0
* 1.1
* 1.2
* 2.0
* 2.1

### Platforms

* Windows 7
* Windows 8 (8.1)
* Windows 10
* Windows Server 2008 (R2)
* Windows Server 2012 (R2)
* Windows Server 2016
* Ubuntu 14.04 
* Ubuntu 16.04
* Rhel 6.5, 7.0

### Dependencies
The following cookbooks are required:

* arcgis-enterprise

Attributes
----------

* `node['arcgis']['insights']['version']` = Insights for ArcGIS version. Default version is `1.0`
* `node['arcgis']['insights']['setup']` = The location of Insights for ArcGIS setup executable. Default location is `%USERPROFILE%\Documents\Insights <version>\Insights\setup.exe` on Windows and `/opt/arcgis/Insights/Insights-Setup.sh` on Linux.
* `node['arcgis']['insights']['setup_archive']` = Path to Insights for ArcGIS setup archive. Default value depends on `node['arcgis']['insights']['version']` attribute value.


Recipes
-------

### arcgis-insights::default
Installs and configures Insights for ArcGIS.

### arcgis-insights::uninstall
Uninstalls Insights for ArcGIS.

Usage
-----

See [wiki](https://github.com/Esri/arcgis-cookbook/wiki) pages for more information about using ArcGIS cookbooks.

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an [issue](https://github.com/Esri/arcgis-cookbook/issues).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

Licensing
---------

Copyright 2018 Esri

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

[](Esri Tags: ArcGIS Insights Chef Cookbook)
[](Esri Language: Ruby)
