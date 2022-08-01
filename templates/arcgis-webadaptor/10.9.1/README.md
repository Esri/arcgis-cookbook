---
layout: default
title: "arcgis-webadaptor template"
category: templates
item: arcgis-webadaptor
version: 10.9.1
latest: false
---

# arcgis-webadaptor Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for different ArcGIS Web Adaptor machine roles.

## System Requirements

Consult the ArcGIS Web Adaptor 10.9.1 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client Versions

* Chef Client 16, or
* Cinc Client 16

### Recommended ArcGIS Chef Cookbooks versions

* 3.8.0

### Supported Platforms

* Windows
  * Windows Server 2016 Standard and Datacenter
  * Windows Server 2019 Standard and Datacenter
  * Windows Server 2022 Standard and Datacenter
* Linux
  * Ubuntu Server 18.04 LTS
  * Ubuntu Server 20.04 LTS
  * Red Hat Enterprise Linux Server 7
  * Red Hat Enterprise Linux Server 8
  * CentOS Linux 7

For Linux deployments, enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory:

Windows

* ArcGIS_Web_Adaptor_for_Microsoft_IIS_1091_180055.exe

Linux

* ArcGIS_Web_Adaptor_Java_Linux_1091_180206.tar.gz
* apache-tomcat-9.0.48.tar.gz (will be downloaded from the internet if not present in the local ArcGIS software repository)
* openjdk-11_linux-x64_bin.tar.gz (will be downloaded from the internet if not present in the local ArcGIS software repository)

> The ArcGIS software repository directory is specified by the arcgis.repository.archives attribute. By default, it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run the Chef client.

> Ensure that the directory specified by the arcgis.repository.setups attribute has enough space for setups extracted from the setup archives.

## Initial Deployment Workflow

The following is the recommended initial deployment workflow for the template machine roles:

1. Install the recommended version of [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run the Chef client on the machines as administrator/superuser using the JSON files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options, see the list of supported attributes described in the arcgis-enterprise cookbook README file.

### ArcGIS Mission Server Web Adaptor Machine

```shell
chef-client -z -j arcgis-mission-server-webadaptor.json
```

### ArcGIS Notebook Server Web Adaptor Machine

```shell
chef-client -z -j arcgis-notebook-server-webadaptor.json
```

### Portal for ArcGIS Web Adaptor Machine

```shell

chef-client -z -j arcgis-portal-webadaptor.json
```

### ArcGIS Server Web Adaptor Machine

```shell
chef-client -z -j arcgis-server-webadaptor.json
```

## Install ArcGIS Web Adaptor Patches and Updates

To install software patches and updates after the initial installation or upgrade of ArcGIS Web Adaptor, download ArcGIS Web Adaptor patches from the global ArcGIS software repository into a local patches folder:

```shell
chef-client -z -j arcgis-webadaptor-patches.json
```

Check the list of patches specified by arcgis.web_adaptor.patches attribute in arcgis-webadaptor-patches-apply.json and apply the patches:

```shell
chef-client -z -j arcgis-webadaptor-patches-apply.json
```

## Upgrade Workflow

> It's not recommended to use the templates to upgrade if the web adaptor was not initially deployed using the templates.

Version 10.9.1 is the first release of the arcgis-webadaptor deployment template. Before version 10.9.1, the JSON files for ArcGIS Web Adaptor machine roles were included in different deployment templates: the arcgis-server template for the web adaptor used with ArcgGIS Server, the arcgis-portal template for the web adaptor used with Portal for ArcGIS, and the notebook-server template for the web adpator used with ArcGIS Notebook Server. The 10.9.1 ArcGIS Web Adaptor upgrade workflows are described in the README files of those templates.

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

### arcgis-mission-server-webadaptor-install

Installs and configures Microsoft IIS web server on Windows and Apache Tomcat application server on Linux. Installs ArcGIS Web Adaptor without registering it.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### arcgis-mission-server-webadaptor

Installs and configures Microsoft IIS web server on Windows and Apache Tomcat application server on Linux, installs ArcGIS Web Adaptor and registers it with ArcGIS Mission Server.

Required attribute changes:

* arcgis.iis.keystore_file - (Windows only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure the HTTPS listener in IIS web server.
* arcgis.iis.keystore_password - (Windows only) Specify password of the SSL certificate file.
* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account.
* arcgis.mission_server.admin_username - Specify ArcGIS Mission Server primary site administrator account user name.
* arcgis.mission_server.admin_password - Specify ArcGIS Mission Server primary site administrator account password.
* arcgis.mission_server.url - Specify ArcGIS Mission Server URL.
* arcgis.mission_server.wa_url - Specify ArcGIS Web Adaptor URL.
* tomcat.keystore_file - (Linux only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure the HTTPS listener in Apache Tomcat.
* tomcat.keystore_type - (Linux only) Specify password of the SSL certificate file.

### arcgis-notebook-server-webadaptor-install

Installs ArcGIS Web Adaptor for ArcGIS Notebook Server without regestering it.

### arcgis-notebook-server-webadaptor

Installs and configures Microsoft IIS web server on Windows and Apache Tomcat application server on Linux, installs ArcGIS Web Adaptor and registers it with ArcGIS Notebook Server.

Required attribute changes:

* arcgis.notebook_server.admin_username - Specify ArcGIS Notebook Server primary site administrator account user name.
* arcgis.notebook_server.admin_password - Specify ArcGIS Notebook Server primary site administrator account password.
* arcgis.notebook_server.url - Specify ArcGIS Notebook Server URL.
* arcgis.notebook_server.wa_url - Specify ArcGIS Web Adaptor URL.
* tomcat.keystore_file - Specify path to the SSL certificate file in PKCS12 format that will be used to configure the HTTPS listener in Apache Tomcat.
* tomcat.keystore_type - Specify password of the SSL certificate file.

### arcgis-notebook-server-webadaptor-unregister

Unregisters all web adaptors from an ArcGIS Notebook Server site.

Required attribute changes:

* arcgis.notebook_server.admin_username - Specify ArcGIS Notebook Server primary site administrator account user name.
* arcgis.notebook_server.admin_password - Specify ArcGIS Notebook Server primary site administrator account password.

### arcgis-mission-server-webadaptor-unregister

Unregisters all web adaptors from an ArcGIS Mission Server site.

Required attribute changes:

* arcgis.mission_server.admin_username - Specify ArcGIS Mission Server primary site administrator account user name.
* arcgis.mission_server.admin_password - Specify ArcGIS Mission Server primary site administrator account password.

### arcgis-portal-webadaptor-install

Installs and configures Microsoft IIS web server on Windows and Apache Tomcat application server on Linux. Installs ArcGIS Web Adaptor for Portal for ArcGIS without registering it.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### arcgis-portal-webadaptor

Installs ArcGIS Web Adaptor and registers it with Portal for ArcGIS.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
* arcgis.portal.url - Portal for ArcGIS URL on the machine.
* arcgis.portal.wa_url - Portal for ArcGIS Web Adaptor URL
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator account user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator account password.
* arcgis.iis.keystore_file - (Windows only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure the HTTPS listener in IIS web server.
* arcgis.iis.keystore_password - (Windows only) Specify password of the SSL certificate file.
* tomcat.keystore_file - (Linux only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure the HTTPS listener in Apache Tomcat.
* tomcat.keystore_password - (Linux only) Specify password of the SSL certificate file

### arcgis-server-webadaptor-install

Installs and configures Microsoft IIS web server on Windows and Apache Tomcat application server on Linux. Installs ArcGIS Web Adaptor without registering it.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### arcgis-server-webadaptor-unregister

Unregisters all ArcGIS Web Adaptors registered with an ArcGIS Server site.

Required attribute changes:

* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password - Specify ArcGIS Server primary site administrator account password.

### arcgis-server-webadaptor

Installs and configures Microsoft IIS web server on Windows and Apache Tomcat application server on Linux, installs ArcGIS Web Adaptor and registers it with ArcGIS Server.

Required attribute changes:

* arcgis.iis.keystore_file - (Windows only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure the HTTPS listener in IIS web server.
* arcgis.iis.keystore_password - (Windows only) Specify password of the SSL certificate file.
* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account.
* arcgis.server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.server.admin_password - Specify ArcGIS Server primary site administrator account password.
* arcgis.server.url - Specify ArcGIS Server URL.
* arcgis.server.wa_url - Specify ArcGIS Web Adaptor URL.
* tomcat.keystore_file - (Linux only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure the HTTPS listener in Apache Tomcat.
* tomcat.keystore_type - (Linux only) Specify password of the SSL certificate file.

### arcgis-webadaptor-patches

Downloads ArcGIS Web Adaptor patches from the global ArcGIS software repository into a local patch folder.

### arcgis-webadaptor-patches-apply

Applies ArcGIS Web Adaptor patches.

### arcgis-webadaptor-s3files

The role downloads ArcGIS Web Adaptor setup archives from the S3 bucket specified by the arcgis.repository.server.s3bucket attribute to the local ArcGIS software repository.

The role requires AWS Tools for PowerShell to be installed on Windows machines and AWS Command Line Interface on Linux machines.  

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key
