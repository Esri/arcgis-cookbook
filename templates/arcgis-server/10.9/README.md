# arcgis-server Deployment Template

Creates any of the following ArcGIS Server sites and federates them with an ArcGIS Enterprise deployment: GIS Server, ArcGIS GeoAnalytics Server, Raster Analytics Server, and Image Server.

## System Requirements

Consult the ArcGIS Server 10.9 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client versions

* Chef Client 15, or
* Cinc Client 15

### Recommended ArcGIS Chef Cookbooks versions

* 3.7.0

### Supported Platforms

* Windows
  * Windows Server 2016 Standard and Datacenter
  * Windows Server 2019 Standard and Datacenter
* Linux
  * Ubuntu Server 18.04 LTS
  * Ubuntu Server 20.04 LTS
  * Red Hat Enterprise Linux Server 7
  * Red Hat Enterprise Linux Server 8
  * CentOS Linux 7

For Linux deployments enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory:

Windows

* ArcGIS_Server_Windows_109_177775.exe
* ArcGIS_Web_Adaptor_for_Microsoft_IIS_109_177789.exe

Linux

* ArcGIS_Server_Linux_109_177864.tar.gz
* ArcGIS_Web_Adaptor_Java_Linux_109_177888.tar.gz
* apache-tomcat-8.5.63.tar.gz (will be downloaded from the internet if not present in the local ArcGIS software repository)
* openjdk-11_linux-x64_bin.tar.gz (will be downloaded from the internet if not present in the local ArcGIS software repository)

> ArcGIS software repository directory is specified by arcgis.repository.archives attribute. By default it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run Chef client.

> Ensure that the directory specified by arcgis.repository.setups attribute has enough space for ArcGIS Enterprise setups extracted from the setup archives.

## Initial Deployment Workflow

The recommended initial deployment workflow for the template machine roles:

1. Install [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run Chef client on machines as administrator/superuser using the json files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options see the list of supported attributes described in arcgis-enterprise cookbook README file.

### File Server Machine

```shell
chef-client -z -j arcgis-server-fileserver.json
```

### First ArcGIS Server Machine

```shell
chef-client -z -j arcgis-server.json
```

### ArcGIS Server Web Adaptor Machine

```shell
chef-client -z -j arcgis-server-webadaptor.json
```

### Additional ArcGIS Server Machines

```shell
chef-client -z -j arcgis-server-node.json
```

### Additional GIS Server Federation Roles

If the ArcGIS Server needs to be federated:

* In GIS Server role

  ```shell
  chef-client -z -j gis-server-federation.json
  ```

* In ArcGIS GeoAnalytics Server role

  ```shell
  chef-client -z -j geoanalytics-federation.json
  ```

* In Raster Analytics Server role

  ```shell
  chef-client -z -j arcgis-server-raster-store.json
  chef-client -z -j rasteranalytics-federation.json
  ```

* In Image Server role

  ```shell
  chef-client -z -j arcgis-server-raster-store.json
  chef-client -z -j imagehosting-federation.json
  ```

## Upgrade Workflow

> It's not recommended to use the templates for upgrades if the sites were not initially deployed using the templates.

This is the first release of arcgis-server deployment template. The recommended upgrade workflow for this template will be provided in the subsequent releases.

## JSON Files Included in the Template

* arcgis-server-s3files - downloads ArcGIS Server setups archives from S3 bucket
* arcgis-server-fileserver - configures file shares for ArcGIS Server config store and server directories
* arcgis-server-install - installs ArcGIS Server without authorizing or configuring
* arcgis-server - installs ArcGIS Server, authorizes the software, and creates ArcGIS Server site
* arcgis-server-node - installs ArcGIS Server, authorizes the software, and joins the machine to ArcGIS Server site
* arcgis-sever-raster-store - registers raster store with ArcGIS Server
* arcgis-server-webadaptor - installs ArcGIS Web Adaptor and registers it with ArcGIS Server
* gis-server-federation - federates ArcGIS Server with Portal for ArcGIS
* imagehosting-federation - federates ArcGIS Server with Portal for ArcGIS in ImageHosting server role
* geoanalytics-federation - federates ArcGIS Server with Portal for ArcGIS in GeoAnalytics server role
* rasteranalytics-federation - federates ArcGIS Server with Portal for ArcGIS in RasterAnalytics server role
* unregister-machine - unregisters server machine from ArcGIS Server site

### arcgis-server-s3files

The role downloads ArcGIS Server setups archives from S3 bucket specified by arcgis.repository.server.s3bucket attribute to the local ArcGIS software repository.

The role requires AWS Tools for PowerShell to be installed on Windows machines and AWS Command Line Interface on Linux machines.  

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key

### arcgis-server-fileserver

Configures file shares for ArcGIS Server config store and server directories.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account

### arcgis-server-install

Installs ArcGIS Server on the machine without authorizing or configuring it.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account

### arcgis-server

Installs ArcGIS Server on the machine, authorizes the software, and creates ArcGIS Server site.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.server.admin_username - Specify primary site administrator account user name.
* arcgis.server.admin_password - Specify primary site administrator account password.
* arcgis.server.authorization_file - Specify path to the ArcGIS Server role software authorization file.
* arcgis.server.directories_root - Replace 'FILESERVER' by the file server machine hostname or static IP address.
* arcgis.server.config_store_connection_string - Replace 'FILESERVER' by the file server machine hostname or static IP address.

### arcgis-server-node

Installs ArcGIS Server on the machine, authorizes the software, and joins the machine to an existing ArcGIS Server site.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password - Specify ArcGIS Server primary site administrator account password.
* arcgis.server.authorization_file - Specify path to the ArcGIS Server role software authorization file.
* arcgis.server.primary_server_url - Specify URL of the ArcGIS Server site to join.

### arcgis-sever-raster-store

Registers raster store with ArcGIS Server.

* arcgis.server.url - Specify ArcGIS Server URL.
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password - Specify ArcGIS Server primary site administrator account password.

### arcgis-server-webadaptor

Installs and configures Microsoft IIS web server on windows and Apache Tomcat application server on Linux, installs ArcGIS Web Adaptor and registers it with ArcGIS Server.

Required attributes changes:

* arcgis.iis.keystore_file - (Windows only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure HTTPS listener in IIS web server.
* arcgis.iis.keystore_password - (Windows only) Specify password of the SSL certificate file.
* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password - Specify ArcGIS Server primary site administrator account password.
* arcgis.server.url - Specify ArcGIS Server URL.
* arcgis.server.wa_url - Specify ArcGIS Web Adaptor URL.
* tomcat.keystore_file - (Linux only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure HTTPS listener in Apache Tomcat.
* tomcat.keystore_type - (Linux only) Specify password of the SSL certificate file.

### gis-server-federation

Federates ArcGIS Server with Portal for ArcGIS.

Required attributes changes:

* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify ArcGIS Server private URL that will be used as the admin URL during federation.
* arcgis.server.web_context_url - Specify ArcGIS Server Web Context URL that be used as the services URL during federation.
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### imagehosting-federation

Federates ArcGIS Server with Portal for ArcGIS in ImageHosting server role.

Required attributes changes:

* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify ArcGIS Server private URL that will be used as the admin URL during federation.
* arcgis.server.web_context_url - Specify ArcGIS Server Web Context URL that be used as the services URL during federation.
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### geoanalytics-federation

Federates ArcGIS Server with Portal for ArcGIS in GeoAnalytics server role.

Required attributes changes:

* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify ArcGIS Server private URL that will be used as the admin URL during federation.
* arcgis.server.web_context_url - Specify ArcGIS Server Web Context URL that be used as the services URL during federation.
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### rasteranalytics-federation

Federates ArcGIS Server with Portal for ArcGIS in RasterAnalytics server role.

Required attributes changes:

* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.server.private_url - Specify ArcGIS Server private URL that will be used as the admin URL during federation.
* arcgis.server.web_context_url - Specify ArcGIS Server Web Context URL that be used as the services URL during federation.
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### unregister-machine

Unregisters the server machine from the ArcGIS Server site.

Required attributes changes:

* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password - Specify ArcGIS Server primary site administrator account password.
* arcgis.server.url - Specify ArcGIS Server URL.
