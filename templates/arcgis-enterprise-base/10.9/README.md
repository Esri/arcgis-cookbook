# arcgis-enterprise-base Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for single-machine and multi-machine base ArcGIS Enterprise deployments.

The base ArcGIS Enterprise deployment machines include the following components:

* Portal for ArcGIS
* ArcGIS Server configured as hosting server for the portal
* ArcGIS Data Store, configured as a relational and tile cache data store
* Two installations of ArcGIS Web Adaptor: one for ArcGIS Enterprise portal and another for the hosting server
  * On Windows the deployment configures Microsoft IIS web server and installs ArcGIS Web Adaptor for Microsoft IIS
  * On Linux the deployment installs Apache Tomcat application server and ArcGIS Web Adaptor (Java Platform)

## System Requirements

Consult the ArcGIS Enterprise 10.9 system requirements documentation for the required/recommended hardware specification.

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

* ArcGIS_DataStore_Windows_109_177788.exe
* ArcGIS_Server_Windows_109_177775.exe
* ArcGIS_Web_Adaptor_for_Microsoft_IIS_109_177789.exe
* Portal_for_ArcGIS_Windows_109_177786.exe
* Portal_for_ArcGIS_Web_Styles_Windows_109_177787.exe

Linux

* ArcGIS_DataStore_Linux_109_177887.tar.gz
* ArcGIS_Server_Linux_109_177864.tar.gz
* ArcGIS_Web_Adaptor_Java_Linux_109_177888.tar.gz
* Portal_for_ArcGIS_Linux_109_177885.tar.gz
* Portal_for_ArcGIS_Web_Styles_Linux_109_177886.tar.gz
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

### Single-machine deployment

The single machine deployment uses one machine for file server and primary machine roles.

```shell
chef-client -z -j arcgis-enterprise-fileserver.json
chef-client -z -j arcgis-enterprise-primary.json
```

> If you don't plan adding standby machine in the future, don't configure the file server and use local paths instead of shared directories for ArcGIS Server server directories, Portal for ArcGIS content directory, and ArcGIS Data Store backup directories in arcgis-enterprise-primary.json.

### Multi-machine deployment

The multi-machine deployment includes the following machine roles:

* File Server Machine
* Primary Base ArcGIS Enterprise Machine
* Standby ArcGIS Enterprise Base Machine

#### File Server Machine

```shell
chef-client -z -j arcgis-enterprise-fileserver.json
```

#### Primary Base ArcGIS Enterprise Machine

After the Chef run on the file server machine is completed run:

```shell
chef-client -z -j arcgis-enterprise-primary.json
```

#### Standby ArcGIS Enterprise Base Machine

After the Chef run on the primary machine is completed run:

```shell
chef-client -z -j arcgis-enterprise-standby.json
```

## Upgrade Workflow

> It's not recommended to use the templates for upgrades if the sites were not initially deployed using the templates.

This is the first release of arcgis-enterprise-base deployment template. The recommended upgrade workflow for this template will be provided in the subsequent releases.

## JSON Files Included in the Template

* arcgis-enterprise-s3files - downloads base ArcGIS Enterprise setups archives from S3 bucket
* arcgis-enterprise-fileserver - configures file shares for the base ArcGIS Enterprise
* arcgis-enterprise-install - installs base ArcGIS Enterprise software without authorizing or configuring
* arcgis-enterprise-primary - installs and configures base ArcGIS Enterprise on primary machine
* arcgis-enterprise-standby - installs and configures base ArcGIS Enterprise on standby machine

### arcgis-enterprise-s3files

The role downloads ArcGIS Enterprise setups archives from S3 bucket specified by arcgis.repository.server.s3bucket attribute to the local ArcGIS software repository.

The role requires AWS Tools for PowerShell to be installed on Windows machines and AWS Command Line Interface on Linux machines.  

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key

### arcgis-enterprise-fileserver

Configures file shares for ArcGIS Server server directories, Portal for ArcGIS content directory, and ArcGIS Data Store backup directories.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account

### arcgis-enterprise-install

Installs base ArcGIS Enterprise software on the machine without authorizing or configuring.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account

### arcgis-enterprise-primary

Installs and configures base ArcGIS Enterprise software on primary machine.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.server.url - ArcGIS Server URL on the machine
* arcgis.server.wa_url - ArcGIS Server Web Adaptor URL on the machine
* arcgis.server.private_url - ArcGIS Server load balanced admin URL that will be used as the federated server admin URL
* arcgis.server.web_context_url - ArcGIS Server web context URL that will be used for the federated server services URL
* arcgis.server.admin_username - Specify primary site administrator account user name
* arcgis.server.admin_password - Specify primary site administrator account password
* arcgis.server.authorization_file - Specify path to the ArcGIS Server role software authorization file
* arcgis.server.directories_root - Replace 'FILESERVER' by the file server machine hostname or static IP address
* arcgis.server.config_store_connection_string - Replace 'FILESERVER' by the file server machine hostname or static IP address
* arcgis.server.system_properties.WebContextURL - ArcGIS Server web context URL used if there is a reverse proxy and\or load balancer
* arcgis.portal.url - Portal for ArcGIS URL on the machine
* arcgis.portal.wa_url - Portal for ArcGIS Web Adaptor URL
* arcgis.portal.private_url - Portal for ArcGIS load balanced admin URL
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator account user name
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator account password
* arcgis.portal.admin_email - Specify Portal for ArcGIS administrator account e-mail
* arcgis.portal.admin_full_name - Specify Portal for ArcGIS administrator account full name
* arcgis.portal.security_question - Specify Portal for ArcGIS administrator account security question (See [Create Site - ArcGIS REST API](https://developers.arcgis.com/rest/enterprise-administration/portal/create-site.htm) for the list of allowed security questions)
* arcgis.portal.security_question_answer - Specify Portal for ArcGIS administrator account security question answer
* arcgis.portal.content_store_connection_string - Replace 'FILESERVER' by the file server machine hostname or static IP address
* arcgis.portal.authorization_file - Specify path to the Portal for ArcGIS software authorization file
* arcgis.portal.user_license_type_id - If left blank, a temporary user type will be assigned to the user and will have to be changed on the first log in (the allowed user type IDs are: creatorUT, GISProfessionalBasicUT, GISProfessionalStdUT, and GISProfessionalAdvUT)
* arcgis.portal.system_properties.privatePortalURL - Portal for ArcGIS load balanced admin URL
* arcgis.portal.system_properties.WebContextURL - Portal for ArcGIS web context URL
* arcgis.iis.keystore_file - (Windows only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure HTTPS listener in IIS web server
* arcgis.iis.keystore_password - (Windows only) Specify password of the SSL certificate file
* tomcat.keystore_file - (Linux only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure HTTPS listener in Apache Tomcat
* tomcat.keystore_password - (Linux only) Specify password of the SSL certificate file

### arcgis-enterprise-standby

Installs and configures base ArcGIS Enterprise software on standby machine.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.server.url - ArcGIS Server URL on the machine
* arcgis.server.wa_url - ArcGIS Server Web Adaptor URL on the machine
* arcgis.server.admin_username - Specify primary site administrator account user name
* arcgis.server.admin_password - Specify primary site administrator account password
* arcgis.server.authorization_file - Specify path to the ArcGIS Server role software authorization file
* arcgis.server.primary_server_url - Specify ArcGIS Server URL on the primary machine
* arcgis.portal.url - Portal for ArcGIS URL on the machine
* arcgis.portal.wa_url - Portal for ArcGIS Web Adaptor URL
* arcgis.portal.private_url - Portal for ArcGIS load balanced admin URL
* arcgis.portal.web_context_url - Portal for ArcGIS web context URL
* arcgis.portal.primary_machine_url - Specify Portal for ArcGIS URL of the primary machine
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator account user name
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator account password
* arcgis.portal.authorization_file - Specify path to the Portal for ArcGIS software authorization file
* arcgis.iis.keystore_file - (Windows only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure HTTPS listener in IIS web server
* arcgis.iis.keystore_password - (Windows only) Specify password of the SSL certificate file
* tomcat.keystore_file - (Linux only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure HTTPS listener in Apache Tomcat application server
* tomcat.keystore_password - (Linux only) Specify password of the SSL certificate file

