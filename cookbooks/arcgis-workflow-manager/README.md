# arcgis-workflow-manager cookbook

This cookbook installs and configures ArcGIS Workflow Manager Server and Web App.

## Requirements

### Supported ArcGIS Workflow Manager Server versions

* 10.8.1
* 10.9
* 10.9.1

### Supported ArcGIS software

* ArcGIS Workflow Manager Server
* ArcGIS Workflow Manager Web App

### Platforms

* Microsoft Windows Server 2019 Standard and Datacenter
* Microsoft Windows Server 2022 Standard and Datacenter
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

* `node['arcgis']['workflow_manager_server']['setup_archive']` = Path to ArcGIS Workflow Manager Server setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['workflow_manager_server']['setup']` = The location of ArcGIS Workflow Manager Server setup executable. Default location is `%USERPROFILE%\Documents\ArcGIS10.9\WorkflowManagerServer\Setup.exe` on Windows and `/opt/arcgis/10.9/WorkflowManagerServer/Setup.sh` on Linux.
* `node['arcgis']['workflow_manager_server']['authorization_file']` = ArcGIS Workflow Manager Server authorization file path. Default value is set to the value of `node['arcgis']['server']['authorization_file']`
* `node['arcgis']['workflow_manager_server']['authorization_file_version']` = ArcGIS Workflow Manager Server authorization file version. Default value is `node['arcgis']['server']['authorization_file_version']`.
* `node['arcgis']['workflow_manager_server']['ports']` = Ports used by ArcGIS Workflow Manager Server. Default ports are `9830,9820,9840,9880,13443`.

Recipes
-------

### arcgis-workflow-manager::default

Installs and authorizes ArcGIS Workflow Manager Server.

### arcgis-workflow-manager::federation

Federates ArcGIS Workflow Manager Server and enables Workflow Manager server function.

### arcgis-workflow-manager::install_server

Installs ArcGIS Workflow Manager Server.

### arcgis-workflow-manager::install_webapp

Installs ArcGIS Workflow Manager Web App.

### arcgis-workflow-manager::server

Installs and authorizes ArcGIS Workflow Manager Server.

### arcgis-workflow-manager::uninstall_server

Uninstalls ArcGIS Workflow Manager Server.

### arcgis-workflow-manager::uninstall_webapp

Uninstalls ArcGIS Workflow Manager Web App.

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

[](Esri Tags: ArcGIS Enterprise Workflow Server Chef Cookbook)
[](Esri Language: Ruby)
