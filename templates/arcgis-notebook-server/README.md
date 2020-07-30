# arcgis-notebook-server Deployment Template

The template contans Chef Zero JSON files with sample recipes and attributes for different ArcGIS Notebook Server machine roles.

## System requirements

Recommended Chef Client version: 14.4.56

Recommended ArcGIS Chef Cookbooks versions:

* 3.5.0 with ArcGIS Notebook Server 10.7.1 & 10.8
* 3.6.0 with ArcGIS Notebook Server 10.8.1

Supported Platforms:

* ubuntu

## Machine Roles

* notebook-server-primary
* notebook-server-node
* notebook-server-federation

### notebook-server-primary

* Installs OpenJDK and Tomcat web server
* Configures iptables to forward port 80 to 8080 and port 443 to 8443.
* Installs NFS and configures shares for ArcGIS Notebook Server config store and server directories.
* Installs the latest version of Docker.
* Installs ArcGIS Notebook Server
* Configures ArcGIS Notebook Server
* Installs and configures ArcGIS Web Adaptor for ArcGIS Notebook Server

### notebook-server-node

* Installs the latest version of Docker
* Installs ArcGIS Notebook Server
* Joins the machine to ArcGIS Notebook Server site on the primary machine

### notebook-server-federation

* Federates ArcGIS Notebook Server with Portal for ArcGIS and enables NotebookServer role.

## Usage

* Replace values of attributes in the role JSON files.
* Run chef zero on the primary machine:

  ```shell
  /opt/chef/bin/chef-client -z -F min --force-formatter --no-color -j notebook-server-primary.json
  ```

* wait until chef run completes
* Run chef zero on the nodes:

  ```shell
  /opt/chef/bin/chef-client -z -F min --force-formatter --no-color -j notebook-server-node.json
  ```
