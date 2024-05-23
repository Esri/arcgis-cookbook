---
layout: default
title: "arcgis-enterprise-base template"
category: templates
item: arcgis-enterprise-base
version: "11.2"
latest: false
---

# arcgis-enterprise-base Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for single-machine and multi-machine base ArcGIS Enterprise deployments.

The base ArcGIS Enterprise deployment machines include the following components:

* Portal for ArcGIS
* ArcGIS Server configured as hosting server for the portal
* ArcGIS Data Store, configured as a relational and tile cache data store
* Two installations of ArcGIS Web Adaptor: one for ArcGIS Enterprise portal and another for the hosting server
  * On Windows, the deployment configures Microsoft IIS web server and installs ArcGIS Web Adaptor for Microsoft IIS
  * On Linux, the deployment installs Apache Tomcat application server and ArcGIS Web Adaptor (Java Platform)

## System Requirements

Consult the ArcGIS Enterprise 11.2 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client versions

* Chef Client 16, or
* Cinc Client 16

### Recommended ArcGIS Chef Cookbooks versions

* 4.2.0

### Supported Platforms

* Windows
  * Windows Server 2016 Standard and Datacenter
  * Windows Server 2019 Standard and Datacenter
  * Windows Server 2022 Standard and Datacenter
* Linux
  * Ubuntu Server 18.04 LTS
  * Ubuntu Server 20.04 LTS
  * Red Hat Enterprise Linux Server 8
  * SUSE Linux Enterprise Server 15
  * Oracle Linux 8
  * Rocky Linux 8
  * AlmaLinux 9

For Linux deployments, enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory for both initial deployments and upgrades:

Windows

* ArcGIS_DataStore_Windows_112_188252.exe
* ArcGIS_Server_Windows_112_188239.exe
* ArcGIS_Web_Adaptor_for_Microsoft_IIS_112_188253.exe
* Portal_for_ArcGIS_Windows_112_188250.exe
* Portal_for_ArcGIS_Web_Styles_Windows_112_188251.exe
* dotnet-hosting-6.0.9-win.exe (Will be downloaded from the internet if the file is not present)
* WebDeploy_amd64_en-US.msi (Will be downloaded from the internet if the file is not present)

Linux

* ArcGIS_DataStore_Linux_112_188340.tar.gz
* ArcGIS_Server_Linux_112_188327.tar.gz
* ArcGIS_Web_Adaptor_Java_Linux_112_188341.tar.gz
* Portal_for_ArcGIS_Linux_112_188338.tar.gz
* Portal_for_ArcGIS_Web_Styles_Linux_112_188339.tar.gz
* apache-tomcat-9.0.48.tar.gz (Alternatively, if it is not present in the local ArcGIS software repository, you can remove the tomcat.tarball_path attribute from the json and it will be downloaded from the internet for you.)
* openjdk-11_linux-x64_bin.tar.gz (Alternatively, if it is not present in the local ArcGIS software repository, you can remove the java.tarball_path attribute from the json and it will be downloaded from the internet for you.)

> The ArcGIS software repository directory is specified by the arcgis.repository.archives attribute. By default, it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run the Chef client.

> Ensure that the directory specified by the arcgis.repository.setups attribute has enough space for ArcGIS Enterprise setups extracted from the setup archives.

## Initial Deployment Workflow

The following is the recommended initial deployment workflow for the template machine roles:

1. Install [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run the Chef client on the machines as administrator/superuser using the JSON files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options, see the list of supported attributes described in arcgis-enterprise cookbook README file.

### Single-machine deployment

The single-machine deployment uses one machine for the file server and primary machine roles.

```shell
chef-client -z -j arcgis-enterprise-fileserver.json
chef-client -z -j arcgis-enterprise-primary.json
```

> If you don't plan to add a standby machine in the future, don't configure the file server, and use local paths instead of shared directories for ArcGIS Server server directories, Portal for ArcGIS content directory, and ArcGIS Data Store backup directories in the  arcgis-enterprise-primary.json file.

> Portal for ArcGIS content directory must exist before running arcgis-enterprise-primary.json. It can either be created manually or by using arcgis-enterprise-fileserver.json.

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

After the Chef run on the file server machine is complete, run the following:

```shell
chef-client -z -j arcgis-enterprise-primary.json
```

#### Standby ArcGIS Enterprise Base Machine

After the Chef run on the primary machine is complete, run the following:

```shell
chef-client -z -j arcgis-enterprise-standby.json
```

## Install Base ArcGIS Enterprise Patches and Updates

To install software patches and updates after the initial installation or upgrade of a base ArcGIS Enterprise deployment, download base ArcGIS Enterprise patches from the global ArcGIS software repository into local patches folder:

```shell
chef-client -z -j arcgis-enterprise-patches.json
```

Check the list of patches specified by the arcgis.portal.patches, arcgis.server.patches, arcgis.data_store.patches, and arcgis.web_adaptor.patches attributes in the arcgis-enterprise-patches-apply.json file, and apply the patches:

```shell
chef-client -z -j arcgis-enterprise-patches-apply.json
```

## Upgrade Workflow

> It's not recommended to upgrade a base ArcGIS Enterprise deployment using the deployment template if it was not initially deployed using an earlier version of the template.

To upgrade a base ArcGIS Enterprise deployed using the arcgis-enterprise-base deployment template to the 11.2 version, you will need:

* ArcGIS 11.2 setup archives,
* ArcGIS 11.2 software authorization files,
* The original JSON files used for the initial deployment or the last upgrade.

### General Upgrade Notes

Upgrading a highly available base ArcGIS Enterprise deployment may take several hours. During that time, the deployment will be unavailable to the users.

Before starting the upgrade process, it's highly recommended to backup ArcGIS Enterprise using the webgisdr utility. To prevent operating system updates during the upgrade process, it's recommended to install all the recommended/required OS updates before upgrading ArcGIS Enterprise.

The attributes defined in the upgrade JSON files must match the actual deployment configuration. To make upgrade JSON files, update the 11.2 template JSON files by copying the attribute values from the JSON files used for the initial deployment or the last upgrade.

> In some cases, the difference between the original and the new deployment template JSON files will be only in the value of arcgis.version attribute. In those cases, the easiest way to make the upgrade JSON files is to change the arcgis.version attribute values to the new version. But the new deployment templates might change recipes in the run_list, add new attributes, and introduce other significant changes. To keep the upgrade JSON files in sync with the new deployment template's version, it's recommended to update the new deployment templates instead of the original JSON files.

The copy_attributes.rb tool can be used to copy attributes values from one JSON file to another. The tool copies only attibutes present in the destination template JSON file. The tool is located in the templates/tools directory in the ArcGIS cookbooks archive. To run copy_attributes.rb, use the chef-apply command that comes with the Chef/Cinc Client.

```shell
chef-apply ./templates/tools/copy_attributes.rb <source JSON file path> <destination template JSON file path>
```

After running the tool, update the destination JSON file attributes that are specific to the new JSON file template and attributes specific to the new ArcGIS Enterprise version, such as software authorization files.

On each deployment machine, before upgrading the ArcGIS Enterprise software, upgrade the configuration management subsystem components:

1. Back up the original JSON files used for the initial deployment or the last upgrade into a local directory.
2. Upgrade [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/) to the recommended version.
3. Empty the Chef/Cinc workspace directory.
4. Download and extract the recommended version of [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef/Cinc workspace directory.

### Upgrade from 10.9, 10.9.1, 11.0, or 11.1

Upgrading base ArcGIS Enterprise deployments from 10.9, 10.9.1, 11.0, 11.1 to 11.2 requires upgrading the primary and standby machines. The file server machine does not require any changes. Steps 1 and 3 are not required for single-machine deployments.

1. Begin the upgrade on the standby machine.

   Copy attributes from the original `arcgis-enterprise-standby.json` JSON file created from the 10.9, 10.9.1, 11.0, or 11.1 arcgis-enterprise-base template to the `arcgis-enterprise-install.json` file of the 11.2 arcgis-enterprise-base template and `arcgis-server-webadaptor-unregister.json` file of the 11.2 arcgis-webadaptor template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/arcgis-enterprise-standby.json <11.2 JSON templates>/arcgis-enterprise-install.json
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/arcgis-enterprise-standby.json <11.2 JSON templates>/arcgis-server-webadaptor-unregister.json
   ```

   Verify that attributes are correct in `arcgis-enterprise-install.json` and `arcgis-server-webadaptor-unregister.json`.

   On the standby machine, run the following command to unregister the ArGIS Web Adaptor used with ArcGIS Server:

   ```shell
   chef-client -z -j <11.2 JSON templates>/arcgis-server-webadaptor-unregister.json
   ```

   Wait until the Chef run completes, and run the following command to begin upgrading the base ArcGIS Enterprise on the machine:

   ```shell
   chef-client -z -j <11.2 JSON templates>/arcgis-enterprise-install.json
   ```

2. Upgrade on the primary machine.

   Copy attributes from the original `arcgis-enterprise-primary.json` JSON file created from the 10.9, 10.9.1, 11.0, or 11.1 arcgis-enterprise-base template to the `arcgis-enterprise-primary.json` file of the 11.2 arcgis-enterprise-base template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/arcgis-enterprise-primary.json <11.2 JSON templates>/arcgis-enterprise-primary.json
   ```

   Verify that attributes are correct in `arcgis-enterprise-primary.json`.

   On the primary machine, run the following command:

   ```shell
   chef-client -z -j <11.2 JSON templates>/arcgis-enterprise-primary.json
   ```

3. Complete upgrading on the standby machine.

   Copy attributes from the original `arcgis-enterprise-standby.json` JSON file created from the 10.9, 10.9.1, 11.0, or 11.1 arcgis-enterprise-base template to the `arcgis-enterprise-standby.json` file of the 11.2 arcgis-enterprise-base template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/arcgis-enterprise-standby.json <11.2 JSON templates>/arcgis-enterprise-standby.json
   ```

   Verify that attributes are correct in `arcgis-enterprise-standby.json`.

   On the standby machine, run the following command:

   ```shell
   chef-client -z -j <11.2 JSON templates>/arcgis-enterprise-standby.json
   ```

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

### arcgis-enterprise-files

The role downloads ArcGIS Enterprise setup archives from https://downloads.arcgis.com to the local ArcGIS software repository specified by the arcgis.repository.local_archives attribute.

If the arcgis.repository.shared attribute is set to `true`, then a network share is created for the local software repository.

On Linux, the role also downloads Apache Tomcat and Open JDK packages from the software vendors' repositories.

Required attribute changes:

* arcgis.repository.server.username - ArcGIS Online user name
* arcgis.repository.server.password - ArcGIS Online user password

### arcgis-enterprise-s3files

The role downloads ArcGIS Enterprise setup archives from the S3 bucket specified by the arcgis.repository.server.s3bucket attribute to the a local ArcGIS software repository.

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key

### arcgis-enterprise-fileserver

Configures file shares for ArcGIS Server server directories, Portal for ArcGIS content directory, and ArcGIS Data Store backup directories.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### arcgis-enterprise-install

Installs base ArcGIS Enterprise software on the machine without authorizing or configuring.

Required attributes changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### arcgis-enterprise-patches

Downloads base ArcGIS Enterprise patches from global ArcGIS software repository into a local patch folder.

### arcgis-enterprise-patches-apply

Applies base ArcGIS Enterprise patches.

### arcgis-enterprise-primary

Installs and configures base ArcGIS Enterprise software on the primary machine.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
* arcgis.server.url - ArcGIS Server URL on the machine
* arcgis.server.wa_url - ArcGIS Server Web Adaptor URL on the machine
* arcgis.server.private_url - ArcGIS Server load balanced admin URL that will be used as the federated server admin URL
* arcgis.server.web_context_url - ArcGIS Server web context URL that will be used for the federated server services URL
* arcgis.server.admin_username - Specify primary site administrator account user name
* arcgis.server.admin_password - Specify primary site administrator account password
* arcgis.server.authorization_file - Specify path to the ArcGIS Server role software authorization file
* arcgis.server.directories_root - Replace 'FILESERVER' with the file server machine hostname or static IP address
* arcgis.server.config_store_connection_string - Replace 'FILESERVER' with the file server machine hostname or static IP address
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
* arcgis.portal.content_store_connection_string - Replace 'FILESERVER' with the file server machine hostname or static IP address
* arcgis.portal.authorization_file - Specify path to the Portal for ArcGIS software authorization file
* arcgis.portal.user_license_type_id - If left blank, a temporary user type will be assigned to the user and will have to be changed on the first log in (the allowed user type IDs are: creatorUT, GISProfessionalBasicUT, GISProfessionalStdUT, and GISProfessionalAdvUT)
* arcgis.portal.system_properties.privatePortalURL - Portal for ArcGIS load balanced admin URL
* arcgis.portal.system_properties.WebContextURL - Portal for ArcGIS web context URL
* arcgis.iis.keystore_file - (Windows only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure the HTTPS listener in IIS web server
* arcgis.iis.keystore_password - (Windows only) Specify password of the SSL certificate file
* tomcat.keystore_file - (Linux only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure the HTTPS listener in Apache Tomcat
* tomcat.keystore_password - (Linux only) Specify password of the SSL certificate file

### arcgis-enterprise-standby

Installs and configures base ArcGIS Enterprise software on the standby machine.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
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
* arcgis.iis.keystore_file - (Windows only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure the HTTPS listener in IIS web server
* arcgis.iis.keystore_password - (Windows only) Specify password of the SSL certificate file
* tomcat.keystore_file - (Linux only) Specify path to the SSL certificate file in PKCS12 format that will be used to configure the HTTPS listener in Apache Tomcat application server
* tomcat.keystore_password - (Linux only) Specify password of the SSL certificate file
