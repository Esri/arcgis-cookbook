arcgis-insights cookbook
===============

This cookbook installs and configures ArcGIS Insights.

Requirements
------------

### Supported ArcGIS Insights versions

* 3.4.1
* 2020.1
* 2020.2
* 2020.3
* 2021.1
* 2021.1.1
* 2021.2
* 2021.2.1
* 2021.3
* 2021.3.1

### Platforms

* Windows 10
* Windows Server 2012 (R2)
* Windows Server 2016
* Windows Server 2019
* Windows Server 2022
* Ubuntu Server 18.04 and 20.04 LTS
* Red Hat Enterprise Linux Server 8
* SUSE Linux Enterprise Server 15
* CentOS Linux 8
* Oracle Linux 8


### Dependencies

The following cookbooks are required:

* arcgis-enterprise
* arcgis-repository

Attributes
----------

* `node['arcgis']['insights']['version']` = ArcGIS Insights version. Default version is `2021.3.1`
* `node['arcgis']['insights']['setup_archive']` = Path to ArcGIS Insights version setup archive. Default value depends on `node['arcgis']['insights']['version']` attribute value.
* `node['arcgis']['insights']['setup']` = The location of ArcGIS Insights setup executable. Default location is `%USERPROFILE%\Documents\Insights <version>\Insights\setup.exe` on Windows and `/opt/arcgis/Insights/Insights-Setup.sh` on Linux.
* `node['arcgis']['insights']['setup_archive']` = Path to ArcGIS Insights setup archive. Default value depends on `node['arcgis']['insights']['version']` attribute value.


Recipes
-------

### arcgis-insights::default

Installs and configures ArcGIS Insights.

### arcgis-insights::uninstall

Uninstalls ArcGIS Insights.

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

[](Esri Tags: ArcGIS Insights Chef Cookbook)
[](Esri Language: Ruby)
