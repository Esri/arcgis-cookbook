esri-tomcat cookbook
====================

This cookbook installs and configures Apache Tomcat for using with ArcGIS Web Adaptor.

Requirements
------------

### Platforms
* Rhel 6, 7
* Ubuntu 14.04

### Dependencies
The following cookbooks are required:
* Tomcat v 2.1
* Java v 1.31
* OpenSSL v 4.0

Attributes
----------
#### General
* `node['tomcat']['version']` = Tomcat version to install. Default is 8.0.33.
* `node['tomcat']['instance_name']` = Default is 'arcgis'.
* `node['tomcat']['instance_path']` = Default is '/opt/tomcat_INSTANCENAME_VERSION'.

#### SSL/TLS
* `node['tomcat']['keystore_file']` = Optional: Path to the keystore file. If not provided, a new file and a self-signed certificate will be created.
* `node['tomcat']['keystore_password']` = Optional: Password to the keystore.
* `node['tomcat']['ssl_enabled_protocols']` = Default is 'TLSv1.2,TLSv1.1,TLSv1'
* `node['tomcat']['domain_name']` = Default is 'Fully Qualified Domain Name'

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

[](Esri Tags: ArcGIS Chef Cookbook Tomcat)
[](Esri Language: Ruby)

