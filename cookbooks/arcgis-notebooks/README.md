---
layout: default
title: "arcgis-notebooks cookbook"
category: cookbooks
item: arcgis-notebooks
version: 4.0.0
latest: true
---

# arcgis-notebooks cookbook

This cookbook installs and configures ArcGIS Notebook Server.

## Supported ArcGIS Notebook Server versions

* 10.8
* 10.8.1
* 10.9
* 10.9.1
* 11.0

## Supported ArcGIS software

* ArcGIS Notebook Server

## Platforms

* Ubuntu Server 18.04 and 20.04 LTS
* Red Hat Enterprise Linux Server 8 (Mirantis Container Runtime must be installed before running Chef)
* Oracle Linux 8

## Dependencies

The following cookbooks are required:

* arcgis-enterprise
* arcgis-repository
* docker
* iptables

## Attributes

* `node['arcgis']['notebook_server']['url']` = The ArcGIS Notebook Server site URL. Default URL is `https://<FQDN of the machine>:11443`.
* `node['arcgis']['notebook_server']['wa_name']` = Name of ArcGIS Web Adaptor used for the ArcGIS Notebook Server site. Default name is `notebooks`.
* `node['arcgis']['notebook_server']['wa_url']` = The URL of the Web Adaptor used for the ArcGIS Notebook Server site. Default URL is `https://<FQDN of the machine>/<Notebook Server Web Adaptor name>`.
* `node['arcgis']['notebook_server']['domain_name']` = The ArcGIS Notebook Server site domain name. Default domain is FQDN of the machine.
* `node['arcgis']['notebook_server']['private_url']` = Private URL of the ArcGIS Notebook Server site. Default URL is `https://<FQDN of the machine>:11443/arcgis`.
* `node['arcgis']['notebook_server']['web_context_url']` = The web context URL of the ArcGIS Notebook Server site. Default URL is `https://<FQDN of the machine>/<Notebook Server Web Adaptor name>`.
* `node['arcgis']['notebook_server']['authorization_file']` = ArcGIS Notebook Server authorization file path.
* `node['arcgis']['notebook_server']['authorization_file_version']` = ArcGIS Notebook Server authorization file version. Default value is `node['arcgis']['server']['authorization_file_version']`.
* `node['arcgis']['notebook_server']['license_level']` = License level of ArcGIS Notebook Server. Allowed values are `standard` and `advanced`. Default license level is `standard`.
* `node['arcgis']['notebook_server']['install_dir']` = ArcGIS Notebook Server installation directory. By default, ArcGIS Notebook Server is installed to  `%ProgramW6432%\ArcGIS\NotebookServer` on Windows machines and to `/home/arcgis` on Linux machines.
* `node['arcgis']['notebook_server']['directories_root']` = The root ArcGIS Notebook Server site's server directory location. The default value is `C:\arcgisnotebookserver\directories` on Windows and `/<ArcGIS Notebook Server install directory>/notebookserver/usr/directories` on Linux.
* `node['arcgis']['notebook_server']['config_store_type']` = The ArcGIS Notebook Server configuration store type `<FILESYSTEM|AMAZON|AZURE>`. Default value is `FILESYSTEM`.
* `node['arcgis']['notebook_server']['config_store_connection_string']` = The configuration store location for the ArcGIS Notebook Server site. By default, the configuration store is created in the local directory `C:\arcgisnotebookserver\config-store` on Windows and `/<ArcGIS Notebook Server install directory>/usr/config-store` on Linux.
* `node['arcgis']['notebook_server']['config_store_class_name']` = The ArcGIS Notebook Server configuration store persistence class name. Default value is `com.esri.arcgis.carbon.persistence.impl.filesystem.FSConfigPersistence`.
* `node['arcgis']['notebook_server']['log_level']` = ArcGIS Notebook Server log level. Default value is `WARNING`.
* `node['arcgis']['notebook_server']['log_dir']` = ArcGIS Notebook Server log directory. Default value is `C:\arcgisnotebookserver\logs` on Windows and `/<ArcGIS Notebook Server install directory>/usr/logs` on Linux.
* `node['arcgis']['notebook_server']['max_log_file_age']` = ArcGIS Notebook Server maximum log file age. Default value is `90`.
* `node['arcgis']['notebook_server']['workspace']` = The workspace directory location. This must be a local path; if the site will have additional machines joined to it, a replication method must be set up between the workspace directories of each machine. By default, the workspace directory is set to `C:\arcgisnotebookserver\arcgisworkspace` on Windows and to `/<ArcGIS Notebook Server install directory>/usr/arcgisworkspace` on Linux.
* `node['arcgis']['notebook_server']['setup_archive']` = Path to the ArcGIS Notebook Server setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['notebook_server']['setup']` = The location of the ArcGIS Notebook Server setup executable. Default location is `%USERPROFILE%\Documents\ArcGIS11.0\NotebookServer\Setup.exe` on Windows and `/opt/arcgis/11.0/NotebookServer_Linux/Setup` on Linux.
* `node['arcgis']['notebook_server']['standard_images']` = Standard Docker container images for notebooks. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['notebook_server']['advanced_images']` = Advanced Docker container images for notebooks. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['notebook_server']['configure_autostart']` = If set to true, on Linux ArcGIS Notebook Server is configured to start with the operating system. Default value is `true`.
* `node['arcgis']['notebook_server']['admin_username']` = Primary ArcGIS Notebook Server administrator user name. Default user name is `admin`.
* `node['arcgis']['notebook_server']['admin_password']` = Primary ArcGIS Notebook Server administrator password. Default value is `change.it`.
* `node['arcgis']['notebook_server']['primary_server_url']` = The URL of the existing ArcGIS Notebook Server site to join, in the format `https://notebookserver.domain.com:11443/arcgis/admin`. Default URL `nil`.
* `node['arcgis']['notebook_server']['install_system_requirements']` = Enable system-level configuration for ArcGIS Notebook Server. Default value is `true`.
* `node['arcgis']['notebook_server']['install_samples_data']` = If set to `true`, the arcgis-notebooks::server recipe includes the arcgis-notebooks::data recipe. Default value is `false`.
* `node['arcgis']['notebook_server']['install_docker']` = If set to `true`, the arcgis-notebooks::docker recipe installs the Docker engine. Default value is `false` for RHEL Linux and `true` otherwise.
* `node['arcgis']['notebook_server']['ports']` = Ports to open for Notebook Servier in the Windows firewall. Default is `11443`.
* `node['arcgis']['notebook_server']['hostname']` = Host name or IP address of ArcGIS Notebook Server machine. Default value is  `''`.
* `node['arcgis']['notebook_server']['system_properties']` = ArcGIS Notebook Server system properties. Default value is `{}`.
* `node['arcgis']['notebook_server']['data_setup']` = The location of the ArcGIS Notebook Server Samples Data setup. Default location is `%USERPROFILE%\Documents\ArcGIS11.0\NotebookServerData\Setup.exe` on Windows and `/opt/arcgis/11.0/NotebookServerData_Linux/ArcGISNotebookServerSamplesData-Setup.sh` on Linux.
* `node['arcgis']['notebook_server']['data_setup_archive']` = Path to the ArcGIS Notebook Server Samples Data setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['notebook_server']['patches]` = File names of ArcGIS Notebook Server patches to install. Default value is `[]`.
  
## Recipes

### default

Calls arcgis-notebooks::server recipe.

### docker

Installs and starts Docker engine. The recipe is supported only on Linux platforms.

Attributes used by the recipe:

```JSON
{
  "run_list": [
    "recipe[arcgis-notebooks::docker]"
  ]
}
```

### federation

Federates ArcGIS Notebook Server with Portal for ArcGIS and enables the Notebook Server role.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "portal": {
            "private_url": "https://portal.domain.com:7443/arcgis",
            "admin_username": "admin",
            "admin_password": "admin123",
            "root_cert": "",
            "root_cert_alias": ""
        },
        "notebook_server": {
            "web_context_url": "https://domain.com/notebooks",
            "private_url": "https://domain.com/notebooks",
            "admin_username": "siteadmin",
            "admin_password": "change.it"
        }
    },
    "run_list": [
        "recipe[arcgis-notebooks::federation]"
    ]
}
```

### install_server

Installs ArcGIS Notebook Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.0",
        "run_as_user": "arcgis",
        "notebook_server": {
            "setup_archive": "/opt/software/esri/ArcGIS_Notebook_Server_Linux_110_183044.tar.gz",
            "standard_images": "/opt/software/esri/ArcGIS_Notebook_Docker_Standard_110_182933.tar.gz",
            "advanced_images": "/opt/software/esri/ArcGIS_Notebook_Docker_Advanced_110_182934.tar.gz",
            "authorization_file": "/opt/software/esri/notebooksadvsvr_110.prvc",
            "license_level": "advanced",
            "install_dir": "/home/arcgis",
            "server_directories_root": "/home/arcgis/notebookserver/usr/directories",
            "config_store_connection_string": "/home/arcgis/notebookserver/usr/directories/config-store",
            "workspace": "/home/arcgis/notebookserver/usr/directories/config-store",
            "configure_autostart": true,
            "install_system_requirements": true,
            "install_samples_data": true
        }
    },
    "run_list": [
        "recipe[arcgis-notebooks::install_server]"
    ]
}
```

### install_server_wa

Installs ArcGIS Web Adaptor for ArcGIS Notebook Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.0",
        "run_as_user": "arcgis",
        "web_server": {
            "webapp_dir": "/opt/tomcat_arcgis/webapps"
        },
        "web_adaptor": {
            "install_dir": "/",
            "setup_archive": "/opt/software/esri/ArcGIS_Web_Adaptor_Java_Linux_110_182987.tar.gz"
        },
        "notebook_server": {
            "wa_name": "notebooks"
        }
    },
    "run_list": [
        "recipe[arcgis-notebooks::install_server_wa]"
    ]
}
```

### install_patches

Installs patches for ArcGIS Notebook Server. The recipe installs patches from the patches folder specified by the arcgis.notebook_server.patches attribute. The patch names may contain a wildcard '\*'. For example, "ArcGIS-1091-*.tar" specifies all .tar patches that start with "ArcGIS-1091-".

Attributes used by the recipe:

```JSON
{
  "arcgis" : {
    "repository" : {
      "patches" : "/opt/software/esri/patches"
    },
    "notebook_server": {
      "patches": ["patch1.tar", "patch2.tar"]
    }
  },
  "run_list": [
    "recipe[arcgis-notebooks::install_patches]"
  ]
}
```

### restart_docker

Restarts the Docker service.

Attributes used by the recipe:

```JSON
{
    "run_list": [
        "recipe[arcgis-notebooks::restart_docker]"
    ]
}
```

### samples_data

Installs ArcGIS Notebook Server Sample Data.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.0",
        "run_as_user": "arcgis",
        "notebook_server": {
            "data_setup_archive": "/opt/software/esri/ArcGIS_Notebook_Server_Samples_Data_Linux_110_183049.tar.gz",
            "install_dir": "/home/arcgis"
        }
    },
    "run_list": [
        "recipe[arcgis-notebooks::samples_data]"
    ]
}
```

### server

Installs and configures ArcGIS Notebook Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.0",
        "run_as_user": "arcgis",
        "notebook_server": {
            "setup_archive": "/opt/software/esri/ArcGIS_Notebook_Server_Linux_110_183044.tar.gz",
            "standard_images": "/opt/software/esri/ArcGIS_Notebook_Docker_Standard_110_182933.tar.gz",
            "advanced_images": "/opt/software/esri/ArcGIS_Notebook_Docker_Advanced_110_182934.tar.gz",
            "authorization_file": "/opt/software/esri/notebooksadvsvr_110.prvc",
            "license_level": "advanced",
            "admin_username": "siteadmin",
            "admin_password": "change.it",
            "install_dir": "/home/arcgis",
            "directories_root": "/home/arcgis/notebookserver/usr/directories",
            "config_store_connection_string": "/home/arcgis/notebookserver/usr/config-store",
            "config_store_type": "FILESYSTEM",
            "workspace": "/home/arcgis/notebookserver/usr/arcgisworkspace",
            "configure_autostart": true,
            "install_system_requirements": true,
            "log_dir": "/home/arcgis/notebookserver/usr/logs",
            "log_level": "WARNING",
            "max_log_file_age": "90",
            "system_properties": {},
            "install_samples_data": false
        }
    },
    "run_list": [
        "recipe[arcgis-notebooks::server]"
    ]
}
```

### server_node

Joins additional machines to an ArcGIS Notebook Server site.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.0",
        "run_as_user": "arcgis",
        "notebook_server": {
            "setup_archive": "/opt/software/esri/ArcGIS_Notebook_Server_Linux_110_183044.tar.gz",
            "standard_images": "/opt/software/esri/ArcGIS_Notebook_Docker_Standard_110_182933.tar.gz",
            "advanced_images": "/opt/software/esri/ArcGIS_Notebook_Docker_Advanced_110_182934.tar.gz",
            "authorization_file": "/opt/software/esri/notebooksadvsvr_110.prvc",
            "license_level": "advanced",
            "admin_username": "siteadmin",
            "admin_password": "change.it",
            "install_dir": "/home/arcgis",
            "primary_server_url": "https://domain.com:11443/arcgis/admin",
            "admin_username": "admin",
            "admin_password": "change.it",
            "configure_autostart": true,
            "install_system_requirements": true
        }
    },
    "run_list": [
        "recipe[arcgis-notebooks::server_node]"
    ]
}
```

### server_wa

Installs and configures ArcGIS Web Adaptor for ArcGIS Notebook Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.0",
        "run_as_user": "arcgis",
        "web_server": {
            "webapp_dir": "/opt/tomcat_arcgis/webapps"
        },
        "web_adaptor": {
            "install_dir": "/",
            "setup_archive": "/opt/software/esri/ArcGIS_Web_Adaptor_Java_Linux_110_182987.tar.gz"
        },
        "notebook_server": {
            "url": "https://hostname:11443",
            "wa_name": "notebooks",
            "wa_url": "https://hostname/notebooks",
            "admin_username": "admin",
            "admin_password": "change.it"
        }
    },
    "run_list": [
        "recipe[arcgis-notebooks::server_wa]"
    ]
}
```

### arcgis-notebooks::uninstall_server

Uninstalls ArcGIS Notebook Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.0",
        "run_as_user": "arcgis",
        "notebook_server": {
            "install_dir": "/home/arcgis"
        }
    },
    "run_list": [
        "recipe[arcgis-notebooks::uninstall_server]"
    ]
}
```

### uninstall_server_wa

Uninstalls ArcGIS Web Adaptor for ArcGIS Notebook Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.0",
        "run_as_user": "arcgis",
        "web_server": {
            "webapp_dir": "/opt/tomcat_arcgis/webapps"
        },
        "web_adaptor": {
            "install_dir": "/"
        },
        "notebook_server": {
            "wa_name": "notebooks"
        }
    },
    "run_list": [
        "recipe[arcgis-notebooks::uninstall_server_wa]"
    ]
}
```

### unregister_server_wa

Unregisters all ArcGIS Web Adaptors from the ArcGIS Notebook Server site.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "notebook_server": {
      "url": "https://hostname:11443/arcgis",
      "admin_username": "siteadmin",
      "admin_password": "change.it"
    }
  },
  "run_list": [
    "recipe[arcgis-notebooks::unregister_server_wa]"
  ]
}
```
