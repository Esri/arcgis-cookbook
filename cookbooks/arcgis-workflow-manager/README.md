---
layout: default
title: "arcgis-workflow-manager cookbook"
category: cookbooks
item: arcgis-workflow-manager
version: 4.0.0
latest: true
---

# arcgis-workflow-manager cookbook

This cookbook installs and configures ArcGIS Workflow Manager Server and Web App.

## Supported ArcGIS Workflow Manager Server versions

* 10.8.1
* 10.9
* 10.9.1
* 11.0

## Supported ArcGIS software

* ArcGIS Workflow Manager Server
* ArcGIS Workflow Manager Web App

## Platforms

* Microsoft Windows Server 2019 Standard and Datacenter
* Microsoft Windows Server 2022 Standard and Datacenter
* Ubuntu Server 18.04 and 20.04 LTS
* Red Hat Enterprise Linux Server 8
* SUSE Linux Enterprise Server 15
* Oracle Linux 8

## Dependencies

The following cookbooks are required:

* arcgis-enterprise
* arcgis-repository

## Attributes

* `node['arcgis']['workflow_manager_server']['setup_archive']` = Path to the ArcGIS Workflow Manager Server setup archive. Default value depends on the `node['arcgis']['version']` attribute value.
* `node['arcgis']['workflow_manager_server']['setup']` = The location of the ArcGIS Workflow Manager Server setup executable. Default location is `%USERPROFILE%\Documents\ArcGIS10.9\WorkflowManagerServer\Setup.exe` on Windows and `/opt/arcgis/10.9/WorkflowManagerServer/Setup.sh` on Linux.
* `node['arcgis']['workflow_manager_server']['authorization_file']` = ArcGIS Workflow Manager Server authorization file path. Default value is set to the value of `node['arcgis']['server']['authorization_file']`
* `node['arcgis']['workflow_manager_server']['authorization_file_version']` = ArcGIS Workflow Manager Server authorization file version. Default value is `node['arcgis']['server']['authorization_file_version']`.
* `node['arcgis']['workflow_manager_server']['ports']` = Ports used by ArcGIS Workflow Manager Server. Default ports are `9830,9820,9840,9880,13443`.
* `node['arcgis']['workflow_manager_server']['patches]` = File names of ArcGIS Workflow Manager Server patches to install. Default value is `[]`.
  
## Recipes

### default

Calls the arcgis-workflow-manager::server recipe.

### federation

Federates ArcGIS Workflow Manager Server with an ArcGIS Enterprise portal and enables the Workflow Manager Server function.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "portal": {
            "private_url": "https://portal.domain.com:7443/arcgis",
            "admin_username": "admin",
            "admin_password": "changeit",
            "root_cert": "",
            "root_cert_alias": ""
        },
        "server": {
            "web_context_url": "https://domain.com/server",
            "private_url": "https://domain.com:6443/arcgis",
            "admin_username": "admin",
            "admin_password": "changeit",
            "is_hosting": true
        }
    },
    "run_list": [
        "recipe[arcgis-workflow-manager::federation]"
    ]
}
```

### install_server

Installs ArcGIS Workflow Manager Server.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.0",
    "run_as_user": "arcgis",
    "run_as_password": "Pa$$w0rdPa$$w0rd",
    "configure_windows_firewall": true,
    "repository": {
      "setups": "C:\\Software\\Setups"
    },
    "server": {
      "install_dir": "C:\\Program Files\\ArcGIS\\Server",
      "install_system_requirements": true
    },
    "workflow_manager_server": {
      "setup_archive": "C:\\Software\\Archives\\ArcGIS_Workflow_Manager_Server_110_182937.exe",
      "setup": "C:\\Software\\Setups\\ArcGIS11.0\\WorkflowManagerServer\\Setup.exe",
      "ports": "9830,9820,9840,9880,13443"      
    }
  },
  "run_list": [
    "recipe[arcgis-workflow-manager::install_server]"
  ]
}
```

### install_patches

Installs patches for ArcGIS Workflow Manager Server. The recipe installs patches from the patches folder specified by the arcgis.notebook_server.patches attribute. The patch names may contain a wildcard '\*'. For example, "ArcGIS-1091-\*.msp" specifies all .msp patches that start with "ArcGIS-1091-".

Attributes used by the recipe:

```JSON
{
  "arcgis" : {
    "repository" : {
      "patches" : "%USERPROFILE%\\Software\\Esri\\patches"
    },
    "workflow_manager_server": {
      "patches": ["patch1.msp", "patch2.msp"]
    }
  },
  "run_list": [
    "recipe[arcgis-workflow-manager::install_patches]"
  ]
}
```

### server

Installs and authorizes ArcGIS Workflow Manager Server.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "version": "11.0",
    "run_as_user": "arcgis",
    "run_as_password": "Pa$$w0rdPa$$w0rd",
    "configure_windows_firewall": true,
    "repository": {
      "setups": "C:\\Software\\Setups"
    },
    "server": {
      "install_dir": "C:\\Program Files\\ArcGIS\\Server",
      "install_system_requirements": true
    },
    "workflow_manager_server": {
      "setup_archive": "C:\\Software\\Archives\\ArcGIS_Workflow_Manager_Server_110_182937.exe",
      "setup": "C:\\Software\\Setups\\ArcGIS11.0\\WorkflowManagerServer\\Setup.exe",
      "authorization_file": "C:\\Software\\AuthorizationFiles\\11.0\\Workflow_Manager_Server.prvc",
      "authorization_file_version": "11.0",
      "ports": "9830,9820,9840,9880,13443"      
    }
  },
  "run_list": [
    "recipe[arcgis-workflow-manager::server]"
  ]
}
```

### uninstall_server

Uninstalls ArcGIS Workflow Manager Server.

```JSON
{
  "arcgis": {
    "version": "11.0",
    "run_as_user": "arcgis",
    "server": {
      "install_dir": "C:\\Program Files\\ArcGIS\\Server"
    }
  },
  "run_list": [
    "recipe[arcgis-workflow-manager::uninstall_server]"
  ]
}
```

### uninstall_webapp

Uninstalls ArcGIS Workflow Manager Web App.

```JSON
{
  "arcgis": {
    "version": "11.0",
    "run_as_user": "arcgis",
    "portal": {
      "install_dir": "C:\\Program Files\\ArcGIS\\Portal"
    }
  },
  "run_list": [
    "recipe[arcgis-workflow-manager::uninstall_webapp]"
  ]
}
```
