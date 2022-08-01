---
layout: default
title: "arcgis-portal template"
category: templates
item: arcgis-portal
version: 11.0
latest: true
---

# arcgis-portal Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for single-machine and highly available Portal for ArcGIS deployments.

## System Requirements

Consult the Portal for ArcGIS 11.0 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client versions

* Chef Client 16, or
* Cinc Client 16

### Recommended ArcGIS Chef Cookbooks versions

* 4.0.0

### Supported Platforms

* Windows
  * Windows Server 2016 Standard and Datacenter
  * Windows Server 2019 Standard and Datacenter
  * Windows Server 2022 Standard and Datacenter  
* Linux
  * Ubuntu Server 18.04 LTS
  * Ubuntu Server 20.04 LTS
  * Red Hat Enterprise Linux Server 8

For Linux deployments, enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory for both initial deployments and upgrades:

Windows

* Portal_for_ArcGIS_Windows_110_182885.exe
* Portal_for_ArcGIS_Web_Styles_Windows_110_182886.exe

Linux

* Portal_for_ArcGIS_Linux_110_182984.tar.gz
* Portal_for_ArcGIS_Web_Styles_Linux_110_182985.tar.gz

> The ArcGIS software repository directory is specified by the arcgis.repository.archives attribute. By default, it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run the Chef client.

> Ensure that the directory specified by the arcgis.repository.setups attribute has enough space for the setups extracted from the setup archives.

## Initial Deployment Workflow

The following is the recommended initial deployment workflow for the template machine roles:

1. Install [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run the Chef client on the machines as administrator/superuser using the JSON files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options, see the list of supported attributes described in the arcgis-enterprise cookbook README file.

### Single-machine deployment

The single-machine deployment uses one machine for the file server and primary machine roles.

```shell
chef-client -z -j arcgis-portal-fileserver.json
chef-client -z -j arcgis-portal-primary.json
```

> If you don't plan to add a standby machine in the future, don't configure the file server, and use local paths instead of shared directories for the Portal for ArcGIS content directory in the arcgis-portal-primary.json file.

### Highly Available Deployment

The multi-machine deployment includes the following machine roles:

* File Server Machine
* Primary Portal for ArcGIS Machine
* Standby Portal for ArcGIS Machine

#### File Server Machine

```shell
chef-client -z -j arcgis-portal-fileserver.json
```

#### Portal for ArcGIS Primary Machine

After the Chef run on the file server machine completes, run the following:

```shell
chef-client -z -j arcgis-portal-primary.json
```

#### Portal for ArcGIS Standby Machine

After the Chef run on the primary machine completes, run the following:

```shell
chef-client -z -j arcgis-portal-standby.json
```

#### ArcGIS Web Adaptor Machines

If ArcGIS Web Adaptor is required, use the arcgis-webadaptor deployment template to install and configure it.

## Install Portal for ArcGIS Patches and Updates

To install software patches and updates after the initial installation or upgrade of Portal for ArcGIS, download Portal for ArcGIS patches from the global ArcGIS software repository into a local patches folder:

```shell
chef-client -z -j arcgis-portal-patches.json
```

Check the list of patches specified by the arcgis.portal.patches attribute in the arcgis-portal-patches-apply.json file, and apply the patches:

```shell
chef-client -z -j arcgis-portal-patches-apply.json
```

## Upgrade Workflow

> It's not recommended to use the templates for upgrades if the portal was not initially deployed using the templates.

To upgrade Portal for ArcGIS deployed using the arcgis-portal deployment template to the 11.0 version, you will need:

* Portal for ArcGIS 11.0 setup archive,
* ArcGIS Web Adaptor 11.0 setup archive, if Web Adaptors were installed in the initial deployment,
* Portal for ArcGIS 11.0 software authorization file,
* The original JSON files used for the initial deployment or the last upgrade.

### General Upgrade Notes

Upgrading the Portal for ArcGIS deployment may take several hours. During that time, the deployment will be unavailable to the users.

Before starting the upgrade process, it's highly recommended to back up Portal for ArcGIS using the webgisdr utility. To prevent operating system updates during the upgrade process, it's recommended to install all the recommended/required OS updates before upgrading Portal for ArcGIS.

The attributes defined in the upgrade JSON files must match the actual deployment configuration. To make upgrade JSON files, update the 11.0 template JSON files by copying the attribute values from the JSON files used for the initial deployment or the last upgrade.

> In some cases, the difference between the original and the new deployment template JSON files will be only in the value of the arcgis.version attribute. In those cases, the easiest way to make the upgrade JSON files is to change the arcgis.version attribute values to the new version. But the new deployment templates might change recipes in the run_list, add new attributes, and introduce other significant changes. To keep the upgrade JSON files in sync with the new deployment templates version, it's recommended to update the new deployment templates instead of the original JSON files.

The copy_attributes.rb tool can be used to copy attribute values from one JSON file to another. The tool copies only attibutes present in the destination template JSON file. The tool is located in the templates/tools directory in the ArcGIS cookbooks archive. To run copy_attributes.rb, use the chef-apply command that comes with the Chef/Cinc Client.

```shell
chef-apply ./templates/tools/copy_attributes.rb <source JSON file path> <destination template JSON file path>
```

After running the tool, update the destination JSON file attributes that are specific to the new JSON file template and attributes specific to the new Portal for ArcGIS version, such as software authorization files.

On each deployment machine, before upgrading the ArcGIS software, upgrade the configuration management subsystem components:

1. Back up the original JSON files used for the initial deployment or the last upgrade into a local directory.
2. Upgrade [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/) to the recommended version.
3. Empty the Chef/Cinc workspace directory.
4. Download and extract the recommended version of [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef/Cinc workspace directory.

### Upgrade from 10.9 or 10.9.1

Upgrading Portal for ArcGIS deployments from 10.9 or 10.9.1 to 11.0 requires upgrading all Portal for ArcGIS machines. The file server machine does not require any changes. Step 1 can be skipped for single-machine Portal for ArcGIS deployments. In each step, wait until the Chef run completes before starting the Chef run of the next step.

> Note that in 11.0, ArcGIS Web Adaptor is installed using the new arcgis-webadaptor deployment template.

1. Upgrade the Portal for ArcGIS standby machine.

   Copy attributes from the original `arcgis-portal-standby.json` JSON file created from the 10.9 or 10.9.1 arcgis-portal template to the `arcgis-portal-install.json` and  `arcgis-portal-standby.json` files of the 11.0 arcgis-portal template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/arcgis-portal-standby.json <arcgis-portal 11.0 template>/arcgis-portal-install.json
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/arcgis-portal-standby.json <arcgis-portal 11.0 template>/arcgis-portal-standby.json
   ```

   Verify that attributes are correct in `arcgis-portal-install.json` and `arcgis-portal-standby.json`.

   On the Portal for ArcGIS standby machine, run the following command:
  
   ```shell
   chef-client -z -j <arcgis-portal 11.0 template>/arcgis-portal-install.json
   ```

   Save the `arcgis-portal-standby.json` file for future upgrades from 11.0 or disaster recovery.

2. Upgrade the Portal for ArcGIS primary machine.
  
   Copy attributes from the original `arcgis-portal-primary.json` JSON file created from the 10.9 or 10.9.1 arcgis-portal template to the `arcgis-portal-primary.json` file of the 11.0 arcgis-portal template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/arcgis-portal-primary.json <arcgis-portal 11.0 template>/arcgis-portal-primary.json
   ```

   Verify that attributes are correct in `arcgis-portal-primary.json`.

   On the Portal for ArcGIS primary machine, run the following command:

   ```shell
   chef-client -z -j <arcgis-portal 11.0 template>/arcgis-portal-primary.json
   ```

3. Upgrade ArcGIS Web Adaptor used with Portal for ArcGIS.

   Copy attributes from the original `arcgis-portal-webadaptor.json` JSON file created from the 10.9 or 10.9.1 arcgis-portal template to the `arcgis-portal-webadaptor.json` file of the 11.0 arcgis-webadaptor template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original JSON files>/arcgis-portal-webadaptor.json <arcgis-webadaptor 11.0 template>/arcgis-portal-webadaptor.json
   ```

   Verify that attributes are correct in `arcgis-portal-webadaptor.json`.

   Run the following command to upgrade ArcGIS Web Adaptor:

   ```shell
   chef-client -z -j <arcgis-webadaptor 11.0 template>/arcgis-portal-webadaptor.json
   ```

   Repeat step 3 for each ArcGIS Web Adaptor machine.

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

### arcgis-portal-files

The role downloads Portal for ArcGIS setups archives from https://downloads.arcgis.com to the local ArcGIS software repository specified by the arcgis.repository.local_archives attribute.

If the arcgis.repository.shared attribute is set to `true`, then a network share is created for the local software repository.

Required attribute changes:

* arcgis.repository.server.username - ArcGIS Online user name
* arcgis.repository.server.password - ArcGIS Online user password

### arcgis-portal-s3files

The role downloads Portal for ArcGIS setups archives from the S3 bucket specified by the arcgis.repository.server.s3bucket attribute to the local ArcGIS software repository.

The role requires AWS Tools for PowerShell to be installed on Windows machines and AWS Command Line Interface on Linux machines.  

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key

### arcgis-portal-fileserver

Configures file shares for the Portal for ArcGIS content directory.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### arcgis-portal-install

Installs Portal for ArcGIS and ArcGIS Web Adaptor on the machine without authorizing or configuring.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### arcgis-portal-patches

Downloads Portal for ArcGIS patches from the global ArcGIS software repository into a local patch folder.

### arcgis-portal-patches-apply

Applies Portal for ArcGIS patches.

### arcgis-portal-primary

Installs and configures Portal for ArcGIS on the primary machine.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
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

### arcgis-portal-standby

Installs and configures Portal for ArcGIS on the standby machine.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account
* arcgis.portal.primary_machine_url - Specify Portal for ArcGIS URL of the primary machine
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator account user name
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator account password
