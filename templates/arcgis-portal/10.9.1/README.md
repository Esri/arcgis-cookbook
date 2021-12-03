# arcgis-portal Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for single-machine and highly available Portal for ArcGIS deployments.

## System Requirements

Consult the Portal for ArcGIS 10.9 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client versions

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
  * CentOS Linux 8

For Linux deployments enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory for both initial deployments and upgrades:

Windows

* ArcGIS_Web_Adaptor_for_Microsoft_IIS_1091_180055.exe
* Portal_for_ArcGIS_Windows_1091_180052.exe
* Portal_for_ArcGIS_Web_Styles_Windows_1091_180053.exe

Linux

* ArcGIS_Web_Adaptor_Java_Linux_1091_180206.tar.gz
* Portal_for_ArcGIS_Linux_1091_180199.tar.gz
* Portal_for_ArcGIS_Web_Styles_Linux_1091_180201.tar.gz
* apache-tomcat-9.0.48.tar.gz (will be downloaded from the internet if not present in the local ArcGIS software repository)
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

> If you don't plan adding standby machine in the future, don't configure the file server and use local paths instead of shared directories for Portal for ArcGIS content directory in arcgis-portal-primary.json.

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

After the Chef run on the file server machine is completed run:

```shell
chef-client -z -j arcgis-portal-primary.json
```

#### Portal for ArcGIS Standby Machine

After the Chef run on the primary machine is completed run:

```shell
chef-client -z -j arcgis-portal-standby.json
```

#### ArcGIS Web Adaptor Machines

If ArcGIS Web Adaptor is required, use arcgis-webadaptor deployment template to install and configure it.

## Upgrade Workflow

> It's not recommended to use the templates for upgrades if the sites were not initially deployed using the templates.

To upgrade base Portal for ArcGIS deployed using arcgis-portal deployment template to 10.9.1 version you will need:

* Portal for ArcGIS 10.9.1 setup archive,
* ArcGIS Web Adaptor 10.9.1 setup archive, if Web Adaptors were installed in the initial deployment,
* Portal for ArcGIS 10.9 software authorization file,
* The original JSON files used for the initial deployment or the last upgrade.

### General Upgrade Notes

Upgrade of Portal for ArcGIS deployment may take several hours, during that time the deployment will be unavailable to the users.

Before starting the upgrade process, it's highly recommended to backup Portal for ArcGIS using webgisdr utility. To prevent operating system updates during the upgrade process it's recommended to install all the recommended/required OS updates before upgrading Portal for ArcGIS.

The attributes defined in the upgrade JSONs files must match the actual deployment configuration. To make upgrade JSON files, update the 10.9.1 template JSON files by copying the attribute values from the JSON files used for the initial deployment or the last upgrade.

> In some cases the difference between the original and the new deployment template JSON files will be just in the value of arcgis.version attribute. In those cases the easiest way to make the upgrade JSON files is just to change arcgis.version attribute values to the new version. But the new deployment templates might change recipes in the run_list, add new attributes, and introduce other significant changes. To keep the upgrade JSON files in sync with the new deployment templates version it's recommended to update the new deployment templates instead of the original JSON files.

Tool copy_attributes.rb can be used to copy attributes values from one JSON file to another. The tool copies only attibutes present in the destination template JSON file. The tool is located in templates/tools directory in the ArcGIS cookbooks archive. To execute copy_attributes.rb use chef-apply command that comes with Chef/Cinc Client.

```shell
chef-apply ./templates/tools/copy_attributes.rb <source JSON file path> <destination template JSON file path>
```

After executing the tool, update the destination JSON file attributes specific to the new JSON file template and attributes specific to the new Portal for ArcGIS version, such as software authorization files.

On each deployment machine, before upgrading the ArcGIS Enterprise software, upgrade the configuration management subsystem components:

1. Backup the original JSON files used for the initial deployment or the last upgrade into a local directory.
2. Upgrade [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/) to the recommended version.
3. Empty the Chef/Cinc workspace directory.
4. Download and extract the recommended version of [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef/Cinc workspace directory.

### Upgrade from 10.9

Upgrading Portal for ArcGIS deployments from 10.9 to 10.9.1 requires upgrading all Portal for ArcGIS machines. The file server machine does not require any changes. Step 1 can be skipped for single machine Portal for ArcGIS deployments. In each step wait until the Chef run completes prior to executing Chef run of the next step.

> Note that in 10.9.1 ArcGIS Web Adaptor is installed using new arcgis-webadaptor deployment template.

1. Upgrade Portal for ArcGIS standby machine

   Copy attributes from the original `arcgis-portal-standby.json` JSON file created from 10.9 arcgis-portal template to `arcgis-portal-install.json` and  `arcgis-portal-standby.json` of 10.9.1 arcgis-portal template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-portal-standby.json <arcgis-portal 10.9.1 template>/arcgis-portal-install.json
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-portal-standby.json <arcgis-portal 10.9.1 template>/arcgis-portal-standby.json
   ```

   Verify that attributes are correct in `arcgis-portal-install.json` and `arcgis-portal-standby.json`.

   On Portal for ArcGIS standby machine execute the following command:
  
   ```shell
   chef-client -z -j <arcgis-portal 10.9.1 template>/arcgis-portal-install.json
   ```

   Save `arcgis-portal-standby.json` file for future upgrades from 10.9.1 or disaster recovery.

2. Upgrade Portal for ArcGIS primary machine
  
   Copy attributes from the original `arcgis-portal-primary.json` JSON file created from 10.9 arcgis-portal template to `arcgis-portal-primary.json` of 10.9.1 arcgis-portal template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-portal-primary.json <arcgis-portal 10.9.1 template>/arcgis-portal-primary.json
   ```

   Verify that attributes are correct in `arcgis-portal-primary.json`.

   On Portal for ArcGIS primary machine execute the following command:

   ```shell
   chef-client -z -j <arcgis-portal 10.9.1 template>/arcgis-portal-primary.json
   ```

3. Upgrade Portal for ArcGIS Web Adaptors

   Copy attributes from the original `arcgis-portal-webadaptor.json` JSON file created from 10.9 arcgis-portal template to `arcgis-portal-webadaptor.json` of 10.9.1 arcgis-webadaptor template.

   ```shell
   chef-apply ./templates/tools/copy_attributes.rb <original 10.9 JSON files>/arcgis-portal-webadaptor.json <arcgis-webadaptor 10.9.1 template>/arcgis-portal-webadaptor.json
   ```

   Verify that attributes are correct in `arcgis-portal-webadaptor.json`.

   Execute the following command to upgrade ArcGIS Web Adaptor:

   ```shell
   chef-client -z -j <arcgis-webadaptor 10.9.1 template>/arcgis-portal-webadaptor.json
   ```

   Repeat step 3 for each ArcGIS Web Adaptor machine.

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

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
