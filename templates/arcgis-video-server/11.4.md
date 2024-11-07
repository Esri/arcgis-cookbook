---
layout: default
title: "arcgis-video-server template"
category: templates
item: arcgis-video-server
version: "11.4"
latest: true
---

# arcgis-video-server Deployment Template

The template contains Chef Zero JSON files with sample recipes and attributes for different ArcGIS Video Server machine roles.

## System Requirements

Consult the ArcGIS Video Server 11.4 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client Versions

* Chef Client 18, or
* Cinc Client 18

### Recommended ArcGIS Chef Cookbooks versions

* 5.1.0

### Supported Platforms

* Windows
  * Windows Server 2016 Standard and Datacenter
  * Windows Server 2019 Standard and Datacenter
  * Windows Server 2022 Standard and Datacenter
* Linux
  * Ubuntu Server 22.04 LTS
  * Ubuntu Server 24.04 LTS
  * Red Hat Enterprise Linux Server 8
  * SUSE Linux Enterprise Server 15
  * Oracle Linux 8

On Linux, enable running sudo without password for the user running the Chef client.

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory for both initial deployments and upgrades:

Windows

* ArcGIS_Video_Server_Windows_114_192955.exe

Linux

* ArcGIS_Video_Server_Linux_114_192993.tar.gz

> The ArcGIS software repository directory is specified by the arcgis.repository.archives attribute. By default, it is set to local directory C:\Software\Archives on Windows and /opt/software/archives on Linux. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run the Chef client.

> Ensure that the directory specified by the arcgis.repository.setups attribute has enough space for setups extracted from the setup archives.

## Initial Deployment Workflow

The following is the recommended initial deployment workflow for the template machine roles:

1. Install the recommended version of [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run the Chef client on the machines as administrator/superuser using the JSON files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options, see the list of supported attributes described in the arcgis-video cookbook README file.

### File Server Machine

```shell
chef-client -z -j video-server-fileserver.json
```

### First ArcGIS Video Server Machine

```shell
chef-client -z -j video-server.json
```

### Additional ArcGIS Video Server Machines

```shell
chef-client -z -j video-server-node.json
```

After all the Video Server machines are configured, federate ArcGIS Video Server with Portal for ArcGIS.

```
chef-client -z -j video-server-federation.json
```

### ArcGIS Web Adaptor Machine

If ArcGIS Web Adaptor is required, use the arcgis-webadaptor deployment template to install and configure it.

## Install ArcGIS Video Server Patches and Updates

To install software patches and updates after the initial installation or upgrade of ArcGIS Video Server, download ArcGIS Video Server patches from the global ArcGIS software repository into a local patches folder:

```shell
chef-client -z -j video-server-patches.json
```

Check the list of patches specified by the arcgis.video_server.patches attribute in the video-server-patches-apply.json file, and apply the patches:

```shell
chef-client -z -j video-server-patches-apply.json
```

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

### video-sever-install

Installs ArcGIS Video Server without authorizing or configuring it.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account

### video-server-patches

Downloads ArcGIS Video Server patches from the global ArcGIS software repository into a local patch folder.

### video-server-patches-apply

Applies ArcGIS Video Server patches.

### video-server

Installs ArcGIS Video Server, authorizes the software, and creates a site.

Required attribute changes:

* arcgis.run_as_password - (Windows only) password of 'arcgis' Windows user account.
* arcgis.video_server.admin_username - Specify primary site administrator account user name.
* arcgis.video_server.admin_password - Specify primary site administrator account password.
* arcgis.video_server.authorization_file - Specify path to the ArcGIS Video Server role software authorization file.
* arcgis.video_server.directories_root - Replace 'FILESERVER' with the file server machine hostname or static IP address.
* arcgis.video_server.config_store_connection_string - Replace 'FILESERVER' with the file server machine hostname or static IP address.

### video-server-federation

* Federates ArcGIS Video Server with Portal for ArcGIS and enables the videoServer role.

Required attribute changes:

* arcgis.video_server.admin_username - Specify ArcGIS Server primary site administrator account user name.
* arcgis.video_server.admin_password- Specify ArcGIS Server primary site administrator account password.
* arcgis.video_server.private_url - Specify ArcGIS Server private URL that will be used as the admin URL during federation.
* arcgis.video_server.web_context_url - Specify ArcGIS Server Web Context URL that will be used as the services URL during federation.
* arcgis.portal.admin_username - Specify Portal for ArcGIS administrator user name.
* arcgis.portal.admin_password - Specify Portal for ArcGIS administrator password.
* arcgis.portal.private_url - Specify Portal for ArcGIS private URL.

### video-server-files

The role downloads ArcGIS Video Server setup archives from https://downloads.arcgis.com to the local ArcGIS software repository specified by the arcgis.repository.local_archives attribute.

If the arcgis.repository.shared attribute is set to `true`, then a network share is created for the local software repository.

Required attribute changes:

* arcgis.repository.server.username - ArcGIS Online user name
* arcgis.repository.server.password - ArcGIS Online user password

### video-server-s3files

The role downloads ArcGIS Video Server setups archives from the S3 bucket specified by the arcgis.repository.server.s3bucket attribute to the local ArcGIS software repository.

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key
