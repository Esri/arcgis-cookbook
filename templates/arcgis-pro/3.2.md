---
layout: default
title: "arcgis-pro template"
category: templates
item: arcgis-pro
version: "3.2"
latest: true
---

# arcgis-pro Deployment Template

Installs ArcGIS Pro 3.2.

## System Requirements

Consult the ArcGIS Pro 3.2 system requirements documentation for the required/recommended hardware specification.

### Recommended Chef Client versions

* Chef Client 16, or
* Cinc Client 16

### Recommended ArcGIS Chef Cookbooks versions

* 4.2.0

### Supported Platforms

* Windows 10
* Windows 11

### Required ArcGIS Software Repository Content

The following ArcGIS setup archives must be available in the ArcGIS software repository directory:

* ArcGISPro_32_188049.exe

> The ArcGIS software repository directory is specified by the arcgis.repository.archives attribute. By default, it is set to local directory C:\Software\Archives. However, it is recommended to create an ArcGIS software repository located on a separate file server that is accessible from all the machines in the deployment for the user account used to run the Chef client.

> Ensure that the directory specified by the arcgis.repository.setups attribute has enough space for the setups extracted from the setup archives.

## Initial Deployment Workflow

The following is the recommended initial deployment workflow for the template machine roles:

1. Install [Chef Client](https://docs.chef.io/chef_install_script/) or [Cinc Client](https://cinc.sh/start/client/).
2. Download and extract [ArcGIS Chef cookbooks](https://github.com/Esri/arcgis-cookbook/releases) into the Chef workspace directory.
3. Update the required attributes within the template JSON files.
4. Run the Chef client on the machines as administrator using the JSON files specific to the machine roles (one machine can be used in multiple roles).

> For additional customization options, see the list of supported attributes described in arcgis-pro cookbook README file.

### Concurrent Use ArcGIS Pro

```shell
chef-client -z -j arcgis-pro-concurrent-use.json
```

### Single Use ArcGIS Pro

```shell
chef-client -z -j arcgis-pro-single-use.json
```

### Named User ArcGIS Pro

```shell
chef-client -z -j arcgis-pro-named-user.json
```

## Machine Roles

The JSON files included in the template provide recipes for the deployment machine roles and the most important attributes used by the recipes.  

### arcgis-pro-s3files

Downloads ArcGIS Pro setup archive from the S3 bucket.

The role requires AWS Tools for PowerShell to be installed on the machine.  

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key

### arcgis-pro-install

Installs ArcGIS Pro without authorizing it.

### arcgis-pro-concurrent-use

Installs ArcGIS Pro and configures it with an existing ArcGIS License Manager.

> The concurrent-use license must be either already authorized via License Manager or needs to be done manually.

Required attribute changes:

* arcgis.pro.esri_license_host - ArcGIS License Server host name

### arcgis-pro-single-use

Installs ArcGIS Pro with a single-use license.

Required attribute changes:

* arcgis.pro.authorization_file - ArcGIS Pro authorization file path

### arcgis-pro-named-user

Installs ArcGIS Pro with a named-user license.

### ms-dotnet-s3files

Downloads Microsoft .NET 6 Desktop Runtime x64 setups archive from the S3 bucket.

The following attributes are required unless the machine is an AWS EC2 instance with a configured IAM Role:

* arcgis.repository.server.aws_access_key - AWS account access key id
* arcgis.repository.server.aws_secret_access_key - AWS account secret access key

### ms-dotnet-install

Installs Microsoft .NET 6 Desktop Runtime x64.
