arcgis-mission cookbook
===============

This cookbook installs and configures ArcGIS Mission Server.

Requirements
------------

### Supported ArcGIS Mission Server versions

* 10.8
* 10.8.1
* 10.9

### Supported ArcGIS software

* ArcGIS Mission Server

### Platforms

* Microsoft Windows Server 2019 Standard and Datacenter
* Microsoft Windows Server 2016 Standard and Datacenter
* Microsoft Windows Server 2012 R2 Standard and Datacenter
* Ubuntu 16.04, 18.04
* Rhel 6.5, 7.0

### Dependencies

The following cookbooks are required:

* arcgis-enterprise
* arcgis-repository

Attributes
----------

* `node['arcgis']['mission_server']['url']` = ArcGIS Mission Server URL. Default URL is `https://<FQDN of the machine>:20443`.
* `node['arcgis']['mission_server']['wa_name']` = Name of ArcGIS Web Adaptor used for ArcGIS Mission Server. Default name is `mission`.
* `node['arcgis']['mission_server']['wa_url']` = URL of the Web Adaptor used for ArcGIS Mission Server. Default URL is `https://<FQDN of the machine>/<Mission Server Web Adaptor name>`.
* `node['arcgis']['mission_server']['domain_name']` = ArcGIS Mission Server site domain name. Default domain is FQDN of the machine.
* `node['arcgis']['mission_server']['private_url']` = Private URL of ArcGIS Mission Server. Default URL is `https://<FQDN of the machine>:20443/arcgis`.
* `node['arcgis']['mission_server']['web_context_url']` = Web Context URL of ArcGIS Mission Server. Default URL is `https://<FQDN of the machine>/<Mission Server Web Adaptor name>`.
* `node['arcgis']['mission_server']['authorization_file']` = ArcGIS Mission Server authorization file path.
* `node['arcgis']['mission_server']['authorization_file_version']` = ArcGIS Mission Server authorization file version. Default value is `node['arcgis']['server']['authorization_file_version']`.
* `node['arcgis']['mission_server']['install_dir']` = ArcGIS Mission Server installation directory. By default, ArcGIS Mission Server is installed to  `%ProgramW6432%\ArcGIS\Mission` on Windows machines and to `/home/arcgis` on Linux machines.
* `node['arcgis']['mission_server']['directories_root']` = The root ArcGIS Mission Server server directory location. The default value is `C:\arcgismissionserver\directories` on Windows and `/<ArcGIS Mission Server install directory>/missionserver/usr/directories` on Linux.
* `node['arcgis']['mission_server']['config_store_type']` = ArcGIS Mission Server config store type (FILESYSTEM|AMAZON|AZURE). Default value is `FILESYSTEM`.
* `node['arcgis']['mission_server']['config_store_connection_string']` = The configuration store location for the ArcGIS Mission Server site. By default, the configuration store is created in the local directory `C:\arcgismissionserver\config-store` on Windows and `/<install directory>/usr/config-store` on Linux.
* `node['arcgis']['mission_server']['config_store_class_name']` = ArcGIS Mission Server config store persistence class name. Default value is `com.esri.arcgis.carbon.persistence.impl.filesystem.FSConfigPersistence`.
* `node['arcgis']['mission_server']['log_level']` = ArcGIS Mission Server log level. Default value is `WARNING`.
* `node['arcgis']['mission_server']['log_dir']` = ArcGIS Mission Server log directory. Default value is `C:\arcgismissionserver\logs` on Windows and `/<install directory>/usr/logs` on Linux.
* `node['arcgis']['mission_server']['max_log_file_age']` = ArcGIS Mission Server maximum log file age. Default value is `90`.
* `node['arcgis']['mission_server']['setup_archive']` = Path to ArcGIS Mission Server setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['mission_server']['setup']` = The location of ArcGIS Mission Server setup executable. Default location is `%USERPROFILE%\Documents\ArcGIS10.8\MissionServer\Setup.exe` on Windows and `/opt/arcgis/10.8/MissionServer_Linux/Setup` on Linux.
* `node['arcgis']['mission_server']['configure_autostart']` = If set to true, on Linux the Mission Server is configured to start with the operating system. Default value is `true`.
* `node['arcgis']['mission_server']['admin_username']` = Primary ArcGIS Mission Server administrator user name. Default user name is `admin`.
* `node['arcgis']['mission_server']['admin_password']` = Primary ArcGIS Mission Server administrator password. Default value is `change.it`.
* `node['arcgis']['mission_server']['primary_server_url']` = The URL of the existing ArcGIS Mission Server site to join, in the format `https://missionserver.domain.com:20443/arcgis/admin`. Default URL `nil`.
* `node['arcgis']['mission_server']['install_system_requirements']` = Enable system-level configuration for ArcGIS Mission Server. Default value is `true`.
* `node['arcgis']['mission_server']['ports']` = Ports to open for ArcGIS Mission Servier in Windows firewall. Default is `20443,20300,20301,20302,20158,20159,20160`.
* `node['arcgis']['mission_server']['system_properties']` = ArcGIS Mission Server system properties. Default value is `{}`.
* `node['arcgis']['mission_server']['hostname']` = Host name or IP address of ArcGIS Mission Server machine. Default value is  `''`.

Recipes
-------

### arcgis-mission::default

Installs and configures ArcGIS Mission Server.

### arcgis-mission::federation

Federates ArcGIS Mission Server with Portal for ArcGIS and enables Mission role.

### arcgis-mission::install_server

Installs ArcGIS Mission Server.

### arcgis-mission::install_server_wa

Installs ArcGIS Web Adaptor for ArcGIS Mission Server.

### arcgis-mission::server

Installs and configures ArcGIS Mission Server.

### arcgis-mission::server_node

Joins additional machines to ArcGIS Mission Server site.

### arcgis-mission::server_wa

Installs and configures ArcGIS Web Adaptor for ArcGIS Mission Server.

### arcgis-mission::uninstall_server

Uninstalls ArcGIS Mission Server.

### arcgis-mission::uninstall_server_wa

Uninstalls ArcGIS Web Adaptor for ArcGIS Mission Server.

### arcgis-notebooks::unregister_machine

Unregisters server machine from the ArcGIS Notebook Server site.

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

[](Esri Tags: ArcGIS Enterprise Mission Server Chef Cookbook)
[](Esri Language: Ruby)
