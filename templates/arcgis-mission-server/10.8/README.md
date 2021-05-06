# arcgis-mission-server Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for different ArcGIS Mission Server machine roles.

## System requirements

Recommended Chef Client version: 14.14.29

Recommended ArcGIS Chef Cookbooks versions:

* 3.6.0

Supported Platforms:

* Windows Server 2019
* Ubuntu 18.04

## Machine Roles

* mission-server-primary
* mission-server-federation
* mission-server-s3files

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

Federates ArcGIS Mission Server with Portal for ArcGIS and enables MissionServer role.

### mission-server-s3files

Downloads ArcGIS Mission Server setups files from S3 bucket to local ArcGIS software repository.

## Usage

* Download ArcGIS Mission Server setups to a local ArcGIS software repository on each machine or,
  if you have an AWS account, specify the AWS access key Id and secret access key in
  mission-server-s3files.json and download the setups from a global ArcGIS software repository in S3.

  ```shell
  chef-client -z -F min --force-formatter --no-color -j mission-server-s3files.json
  ```

* Replace values of attributes in the role JSON files.
* Run chef zero on the primary machine:

  ```shell
  chef-client -z -F min --force-formatter --no-color -j mission-server-primary.json
  ```

* wait until chef run completes

* Run chef zero to complete the federation:

  ```shell
  chef-client -z -F min --force-formatter --no-color -j mission-server-federation.json
  ```
