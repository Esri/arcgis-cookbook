arcgis-geoevent cookbook
===============

This cookbook installs and configures ArcGIS GeoEvent Server.

Requirements
------------

### Supported ArcGIS versions

* 10.7
* 10.7.1
* 10.8
* 10.8.1
* 10.9
* 10.9.1

### Supported ArcGIS software

* ArcGIS GeoEvent Server

### Platforms

* Windows 8 (8.1)
* Windows 10
* Windows Server 2008 (R2)
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

* `node['arcgis']['geoevent']['authorization_file']` = ArcGIS GeoEvent Server authorization file path. 
* `node['arcgis']['geoevent']['authorization_file_version']` = ArcGIS GeoEvent Server authorization file version. Default value is `node['arcgis']['server']['authorization_file_version']`.
* `node['arcgis']['geoevent']['setup_archive']` = Path to ArcGIS GeoEvent Server setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['geoevent']['setup']` = The location of ArcGIS GeoEvent Server setup executable. Default location is `%USERPROFILE%\Documents\ArcGIS10.7\ArcGISGeoEventServer\Setup.exe` on Windows and `/opt/arcgis/10.7/geoevent/Setup.sh` on Linux.
* `node['arcgis']['geoevent']['configure_autostart']` = If set to true, on Linux the GeoEvent Server is configured to start with the operating system.  Default value is `true`.
* `node['arcgis']['geoevent']['ports']` = Ports to open for GeoEvent. Default depends on `node['arcgis']['version']`.


Recipes
-------

### arcgis-geoevent::admin_reset

Administratively resets GeoEvent Server.

> Deletes the Apache ZooKeeper files (to administratively clear the GeoEvent Server configuration), the product’s runtime files (to force the system framework to be rebuilt), and removes previously received event messages (by deleting Kafka topic queues from disk) is how system administrators reset a GeoEvent Server instance to look like the product has just been installed.

> If you have custom components in the C:\Program Files\ArcGIS\Server\GeoEvent\deploy folder, move these from the \deploy folder to a local temporary folder, while GeoEvent Server is running, to prevent the component from being restored (from the distributed configuration store) when GeoEvent Server is restarted. Also, make sure you have a copy of the most recent XML export of your GeoEvent Server configuration if you want to save the elements you have created.

### arcgis-geoevent::default

Installs and configures ArcGIS GeoEvent Server.

### arcgis-geoevent::lp-install

Installs language pack for ArcGIS GeoEvent Server.

### arcgis-geoevent::start_server

Starts ArcGIS GeoEvent Server.

### arcgis-geoevent::stop_server

Stops ArcGIS GeoEvent Server.

### arcgis-geoevent::uninstall
Uninstalls ArcGIS GeoEvent Server.


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

[](Esri Tags: ArcGIS Enterprise GeoEvent Server Chef Cookbook)
[](Esri Language: Ruby)
