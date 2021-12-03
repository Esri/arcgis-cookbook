esri-tomcat cookbook
====================

This cookbook installs and configures Apache Tomcat for using with ArcGIS Web Adaptor.

Requirements
------------

### Platforms

* Ubuntu Server 18.04 and 20.04 LTS
* Red Hat Enterprise Linux Server 8
* SUSE Linux Enterprise Server 15
* CentOS Linux 8
* Oracle Linux 8

### Dependencies

The following cookbooks are required:
* tomcat
* openssl

Attributes
----------

#### General

* `node['tomcat']['version']` = Tomcat version to install. Default is `9.0.48`.
* `node['tomcat']['instance_name']` = tomcat instance name. Default is `arcgis`.
* `node['tomcat']['install_path']` = tomcat installation directory. Default is `/opt/tomcat_INSTANCENAME_VERSION`.
* `node['tomcat']['tarball_path']` = tomcat tarball archive path. Default is `<Chef file cache path>/apache-tomcat-<tomcat version>.tar.gz`.
* `node['tomcat']['verify_checksum']` = Verify checksum of downloaded tomcat tarball. Default value is `true`.
* `node['tomcat']['forward_ports']` = If set to `true`, default recipe includes 'firewalld' or 'iptables' recipe. Default value is `true`.
* `node['tomcat']['firewalld']['init_cmd']` = firewalld initialization command. The default command is `firewall-cmd --zone=public --permanent --add-port=0-65535/tcp`.

#### SSL/TLS

* `node['tomcat']['keystore_file']` = Optional: Path to the keystore file. If not provided, a new file and a self-signed certificate will be created.
* `node['tomcat']['keystore_password']` = Optional: Password to the keystore.
* `node['tomcat']['ssl_enabled_protocols']` = SSL protocols of HTTPS listener. Default is `TLSv1.3,TLSv1.2`.
* `node['tomcat']['domain_name']` = Domain name for generated self-signed SSL certificate. Default is `Fully Qualified Domain Name`.

#### OpenJDK

* `node['java']['version']` = Major java version. Default version is `11`.
* `node['java']['tarball_uri']` = JDK tarball URI. Default URI is `https://download.java.net/java/ga/jdk11/openjdk-11_linux-x64_bin.tar.gz`.
* `node['java']['tarball_path']` = JDK tarball local path. Default path is `<file_cache_path>/openjdk-11_linux-x64_bin.tar.gz`.
* `node['java']['install_path']` = JDK installation path. Default path is `/opt`.


Recipes
-------

### esri-tomcat::default

Installs and configures Apache Tomcat application server for ArcGIS Web Adaptor. 

If node['tomcat']['forward_ports'] attribute is `true` (default value), the recipe also configures port forwarding (80 to 8080 and 443 to 8443) using iptables or firewalld recipes.

### esri-tomcat::install

Installs Apache Tomcat application server.

### esri-tomcat::configure_ssl

Configures HTTPS listener in Apache Tomcat application server.

### esri-tomcat::iptables

Installs iptables and configures HTTP(S) port forwarding (80 to 8080 and 443 to 8443).

### esri-tomcat::firewalld

Installs FirewallD and configures HTTP(S) port forwarding (80 to 8080 and 443 to 8443).

> If firewalld service was started by the recipe, the recipe execute script specified by `node['tomcat']['firewalld']['init_cmd']` which by default opens all the TCP ports on the machine.

### esri-tomcat::openjdk

Installs OpenJDK for Apache Tomcat from a local ur remote tarball.

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an [issue](https://github.com/Esri/arcgis-cookbook/issues).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

Licensing
---------

Copyright 2016-2021 Esri

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
