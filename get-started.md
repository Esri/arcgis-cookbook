---
layout: default
title: "Get Started"
category: overview
item: get-started
version: 4.2.0
latest: true
order: 2
---

# Get Started

The easiest way to get started with Chef Cookbooks for ArcGIS is to use them with Cinc Client in local mode. The typical workflow includes the following steps on each machine:

* Installing Cinc Client
* Downloading Chef Cookbooks for ArcGIS
* Downloading ArcGIS Setups
* Running Cinc Client in Local Mode
* Cleaning Up

## Install Cinc Client

[CINC](https://cinc.sh/) is a community distribution of the open source software of Chef Software Inc. Cinc Client is a runtime for Chef cookbooks similar to Chef Infra Client. Chef Cookbooks for ArcGIS support Cinc Client as well as Chef Infra Client.

Cinc Client and all the required Chef cookbooks must be installed on each machine of the deployment.

See [cookbooks version compatibility]({{ site.baseurl }}/versions.html) page for the Cinc Client version recommended for specific ArcGIS software versions.

### On Windows

To install the latest 16.x of Cinc Client, open a Windows PowerShell terminal as administrator and run:

```powershell
> . { iwr -useb https://omnitruck.cinc.sh/install.ps1 } | iex; install -version 16
```

### On Linux

To install the latest 16.x of Cinc Client, open a terminal and run the following command as superuser:

```bash
$ curl -L https://omnitruck.cinc.sh/install.sh | sudo bash -s -- -v 16
```

## Download Chef Cookbooks and Deployment Templates

Download [arcgis-4.2.0-cookbooks.zip/tar.gz](https://github.com/Esri/arcgis-cookbook/releases/tag/v4.2.0) from Chef Cookbooks for ArcGIS [releases](https://github.com/Esri/arcgis-cookbook/releases) on GitHub to the machine and extract the contents of the archive to `/var/cinc` on Linux and `C:\cinc` on Windows.

The archive contains ArcGIS-specific [Chef cookbooks]({{ site.baseurl }}/cookbooks.html), required third-party cookbooks, and [deployment templates]({{ site.baseurl }}/templates.html) for various ArcGIS configurations. The deployment templates located in 'templates' directory inside the archive provide template JSON files for different machine roles, ArcGIS software versions, and platforms.

## Edit Role JSON Files

Select a deployment template for the required ArcGIS subsystem, software version, and platform (Windows/Linux).

All the role JSON files in the deployment templates contain a `run_list` array that defines a list of recipes to run and attributes used by these recipes. The recipes are specified as `<cookbook name>::<recipe name>`.

Follow the instructions for the specific deployment template and the machine role for the required changes of attribute values.

## Download ArcGIS Setups

The deployment templates require specific ArcGIS setup archives to install ArcGIS software. The setup archives must be located in a local or shared ArcGIS software repository directory specified by the `arcgis.repository.archives` attribute. The setup archives used by a deployment template can be downloaded to a local folder from https://downloads.arcgis.com repository using *-files.json files provided by each deployment template. This requires providing ArcGIS Online user name and password in the JSON file.

For multi-machine deployments, it's recommended to use a shared ArcGIS software repository directory instead of downloading the setup archives on each machine. If `arcgis.repository.shared` attribute in the *-files.json file is set to `true`, a network share is created for the local software directory.

## Run Cinc Client in Local Mode

To execute recipes specified in the run_list in a role JSON file, run cinc-client on the machine as administrator/superuser.

### On Windows

To execute recipes specified in the run_list in a role JSON file, run cinc-client on the machine as administrator.

```powershell
> cinc-client -z -j <machine role JSON file path> --config-option cookbook_path=C:\cinc\cookbooks
```

### On Linux

To execute recipes specified in the run_list in a role JSON file, run cinc-client on the machine as superuser.

```bash
$ cinc-client -j <machine role JSON file path> --config-option cookbook_path=/var/cinc/cookbooks
```

## Clean Up

Once all the Chef runs successfully complete, save the JSON files in a safe and secure place to use in the future for upgrades or disaster recovery.

The cinc-client reads attributes from the JSON files and caches the attributes inside a 'nodes' folder that resides in the Chef workspace directory. Because some of the attributes in the JSON file may contain sensitive information, such as passwords, it is recommended that you delete the 'nodes' folder in the Chef workspace directory after you complete the last Chef run on the machine.

Chef Cookbooks for ArcGIS extract the setup archives into the local directory specified by `arcgis.repository.setups` attribute. To save disk space, the archives and setups can be deleted after the machine configuration is completed.
