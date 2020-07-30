# arcgis-mission-server Deployment Template

The template contans Chef Zero JSON files with sample recipes and attributes for different ArcGIS Mission Server machine roles.

## System requirements

Recommended Chef Client version: 14.14.29

Recommended ArcGIS Chef Cookbooks versions:

* 3.6.0 with ArcGIS Mission Server 10.8 & 10.8.1

Supported Platforms:

* Ubuntu
* Windows

## Machine Roles

* mission-server-primary
* mission-server-federation

### mission-server-primary (Ubuntu)

* Installs OpenJDK and Tomcat web server
* Configures iptables to forward port 80 to 8080 and port 443 to 8443
* Installs ArcGIS Mission Server
* Configures ArcGIS Mission Server
* Installs and configures ArcGIS Web Adaptor for ArcGIS Mission Server

### mission-server-primary (Windows)

* Installs and configures IIS
* Installs ArcGIS Mission Server
* Configures ArcGIS Mission Server
* Installs and configures ArcGIS Web Adaptor for ArcGIS Mission Server

### mission-server-federation

* Federates ArcGIS Mission Server with Portal for ArcGIS and enables MissionServer role.

## Usage

* Replace values of attributes in the role JSON files.
* Run chef zero on the primary machine:

  ```shell
  /opt/chef/bin/chef-client -z -F min --force-formatter --no-color -j mission-server-primary.json
  ```

* wait until chef run completes

* Run chef zero to complete the federation:

  ```shell
  /opt/chef/bin/chef-client -z -F min --force-formatter --no-color -j mission-server-federation.json
  ```
