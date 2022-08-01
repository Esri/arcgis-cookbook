# arcgis-portal Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for single-machine and highly available Portal for ArcGIS deployments.

## System Requirements

Consult the Portal for ArcGIS 10.9 system requirements documentation for the required/recommended hardware specification.

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

* ArcGIS_Web_Adaptor_for_Microsoft_IIS_109_177789.exe
* Portal_for_ArcGIS_Windows_109_177786.exe
* Portal_for_ArcGIS_Web_Styles_Windows_109_177787.exe

Linux

* ArcGIS_Web_Adaptor_Java_Linux_109_177888.tar.gz
* Portal_for_ArcGIS_Linux_109_177885.tar.gz
* Portal_for_ArcGIS_Web_Styles_Linux_109_177886.tar.gz
* apache-tomcat-8.5.63.tar.gz (will be downloaded from the internet if not present in the local ArcGIS software repository)
* openjdk-11_linux-x64_bin.tar.gz (will be downloaded from the internet if not present in the local ArcGIS software repository)

> ArcGIS software repository directory is specified by arcgis.repository.archives attribute. By default it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run Chef client.

> Ensure that the directory specified by arcgis.repository.setups attribute has enough space for the setups extracted from the setup archives.

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
chef-client -z -j arcgis-portal-fileserver.json
chef-client -z -j arcgis-portal-primary.json
```

> If you don't plan adding standby machine in the future, don't configure the file server and use local paths instead of shared directories for ArcGIS Server server directories, Portal for ArcGIS content directory, and ArcGIS Data Store backup directories in arcgis-portal-primary.json.

### Highly Available Deployment

The multi-machine deployment includes the following machine roles:

* File Server Machine
* Primary Portal for ArcGIS Machine
* Standby Portal for ArcGIS Machine

#### File Server Machine

```shell
chef-client -z -j arcgis-portal-fileserver.json
```

#### Primary Portal for ArcGIS Machine

After the Chef run on the file server machine is completed run:

```shell
chef-client -z -j arcgis-portal-primary.json
chef-client -z -j arcgis-portal-webadaptor.json
```

#### Standby Portal for ArcGIS Machine

After the Chef run on the primary machine is completed run:

```shell
chef-client -z -j arcgis-portal-standby.json
chef-client -z -j arcgis-portal-webadaptor.json
```


## Upgrade Workflow

> It's not recommended to use the templates for upgrades if the sites were not initially deployed using the templates.

This is the first release of arcgis-portal deployment template. The recommended upgrade workflow for this template will be provided in the subsequent releases.

## JSON Files Included in the Template

* arcgis-portal-s3files - downloads Portal for ArcGIS setups archives from S3 bucket
* arcgis-portal-fileserver - configures file shares for Portal for ArcGIS
* arcgis-portal-install - installs Portal for ArcGIS software without authorizing or configuring
* arcgis-portal-primary - installs and configures Portal for ArcGIS on primary machine
* arcgis-portal-standby - installs and configures Portal for ArcGIS on standby machine
* arcgis-portal-webadaptor - installs ArcGIS Web Adaptor and registers it with Portal for ArcGIS

### arcgis-portal-s3files

The role downloads Portal for ArcGIS setups archives from S3 bucket specified by arcgis.repository.server.s3bucket attribute to the local ArcGIS software repository.

The role requires AWS Tools for PowerShell to be installed on Windows machines and AWS Command Line Interface on Linux machines.  

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key

### arcgis-portal-fileserver

Configures file shares for Portal for ArcGIS content directory.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account

### arcgis-portal-install

Installs Portal for ArcGIS and ArcGIS Web Adaptor on the machine without authorizing or configuring.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account

### arcgis-portal-primary

Installs and configures Portal for ArcGIS on primary machine.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
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

### arcgis-portal-standby

Installs and configures Portal for ArcGIS on standby machine.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.portal.primary_machine_url - Specify Portal for ArcGIS URL of the primary machine
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator account user name
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator account password
* arcgis.portal.authorization_file - Specify path to the Portal for ArcGIS software authorization file

### arcgis-portal-webadaptor

Installs ArcGIS Web Adaptor and registers it with Portal for ArcGIS.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' windows user account
* arcgis.portal.url - Portal for ArcGIS URL on the machine
* arcgis.portal.wa_url - Portal for ArcGIS Web Adaptor URL
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator account user name
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator account password
* arcgis.iis.keystore_file - (Windows only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure HTTPS listener in IIS web server
* arcgis.iis.keystore_password - (Windows only) Specify password of the SSL certificate file
* tomcat.keystore_file - (Linux only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure HTTPS listener in Apache Tomcat
* tomcat.keystore_password - (Linux only) Specify password of the SSL certificate file
