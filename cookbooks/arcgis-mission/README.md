---
layout: default
title: "arcgis-mission cookbook"
category: cookbooks
item: arcgis-mission
version: 5.0.0
latest: true
---

# arcgis-mission cookbook

This cookbook installs and configures ArcGIS Mission Server.

## Supported ArcGIS Mission Server versions

* 10.9.1
* 11.0
* 11.1
* 11.2
* 11.3

## Supported ArcGIS software

* ArcGIS Mission Server

## Platforms

* Microsoft Windows Server 2012 R2 Standard and Datacenter
* Microsoft Windows Server 2016 Standard and Datacenter
* Microsoft Windows Server 2019 Standard and Datacenter
* Microsoft Windows Server 2022 Standard and Datacenter
* Ubuntu Server 20.04 LTS
* Ubuntu Server 22.04 LTS
* Red Hat Enterprise Linux Server 8
* Red Hat Enterprise Linux Server 9
* SUSE Linux Enterprise Server 15
* Oracle Linux 8
* Oracle Linux 9
* Rocky Linux 8
* Rocky Linux 9
* AlmaLinux 9

## Dependencies

The following cookbooks are required:

* arcgis-enterprise
* arcgis-repository

## Attributes

* `node['arcgis']['mission_server']['url']` = The ArcGIS Mission Server URL. Default URL is `https://<FQDN of the machine>:20443`.
* `node['arcgis']['mission_server']['wa_name']` = Name of the ArcGIS Web Adaptor used for the ArcGIS Mission Server site. Default name is `mission`.
* `node['arcgis']['mission_server']['wa_url']` = The URL of the Web Adaptor used for the ArcGIS Mission Server site. Default URL is `https://<FQDN of the machine>/<Mission Server Web Adaptor name>`.
* `node['arcgis']['mission_server']['domain_name']` = The ArcGIS Mission Server site domain name. Default domain is FQDN of the machine.
* `node['arcgis']['mission_server']['private_url']` = Private URL of the ArcGIS Mission Server site. Default URL is `https://<FQDN of the machine>:20443/arcgis`.
* `node['arcgis']['mission_server']['web_context_url']` = Web Context URL of the ArcGIS Mission Server site. Default URL is `https://<FQDN of the machine>/<Mission Server Web Adaptor name>`.
* `node['arcgis']['mission_server']['authorization_file']` = The ArcGIS Mission Server authorization file path.
* `node['arcgis']['mission_server']['authorization_file_version']` = The ArcGIS Mission Server authorization file version. Default value is `node['arcgis']['server']['authorization_file_version']`.
* `node['arcgis']['mission_server']['install_dir']` = The ArcGIS Mission Server installation directory. By default, ArcGIS Mission Server is installed to `%ProgramW6432%\ArcGIS\Mission` on Windows machines and to `/home/arcgis` on Linux machines.
* `node['arcgis']['mission_server']['directories_root']` = The root ArcGIS Mission Server site's server directory location. The default value is `C:\arcgismissionserver\directories` on Windows and `/<ArcGIS Mission Server install directory>/missionserver/usr/directories` on Linux.
* `node['arcgis']['mission_server']['config_store_type']` = The ArcGIS Mission Server configuration store type `<FILESYSTEM|AMAZON|AZURE>`. Default value is `FILESYSTEM`.
* `node['arcgis']['mission_server']['config_store_connection_string']` = The configuration store location for the ArcGIS Mission Server site. By default, the configuration store is created in the local directory `C:\arcgismissionserver\config-store` on Windows and `/<install directory>/usr/config-store` on Linux.
* `node['arcgis']['mission_server']['config_store_class_name']` = The ArcGIS Mission Server configuration store persistence class name. Default value is `com.esri.arcgis.carbon.persistence.impl.filesystem.FSConfigPersistence`.
* `node['arcgis']['mission_server']['log_level']` = ArcGIS Mission Server log level. Default value is `WARNING`.
* `node['arcgis']['mission_server']['log_dir']` = ArcGIS Mission Server log directory. Default value is `C:\arcgismissionserver\logs` on Windows and `/<install directory>/usr/logs` on Linux.
* `node['arcgis']['mission_server']['max_log_file_age']` = ArcGIS Mission Server maximum log file age. Default value is `90`.
* `node['arcgis']['mission_server']['setup_archive']` = Path to the ArcGIS Mission Server setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['mission_server']['setup']` = The location of the ArcGIS Mission Server setup executable. Default location is `%USERPROFILE%\Documents\ArcGIS11.3\MissionServer\Setup.exe` on Windows and `/opt/arcgis/11.3/MissionServer/Setup` on Linux.
* `node['arcgis']['mission_server']['configure_autostart']` = If set to true, on Linux the Mission Server is configured to start with the operating system. Default value is `true`.
* `node['arcgis']['mission_server']['admin_username']` = Primary ArcGIS Mission Server administrator user name. Default user name is `siteadmin`.
* `node['arcgis']['mission_server']['admin_password']` = Primary ArcGIS Mission Server administrator password. Default value is `nil`.
* `node['arcgis']['mission_server']['primary_server_url']` = The URL of the existing ArcGIS Mission Server site to join, in the format `https://missionserver.domain.com:20443/arcgis/admin`. Default URL `nil`.
* `node['arcgis']['mission_server']['install_system_requirements']` = Enable system-level configuration for ArcGIS Mission Server. Default value is `true`.
* `node['arcgis']['mission_server']['ports']` = Ports to open for ArcGIS Mission Servier in the Windows firewall. Default is `20443,20301,20160`.
* `node['arcgis']['mission_server']['system_properties']` = ArcGIS Mission Server system properties. Default value is `{}`.
* `node['arcgis']['mission_server']['hostname']` = Host name or IP address of the ArcGIS Mission Server machine. Default value is  `''`.
* `node['arcgis']['mission_server']['patches]` = File names of ArcGIS Mission Server patches to install. Default value is `[]`.

## Recipes

### default

Calls arcgis-mission::server recipe.

### federation

Federates ArcGIS Mission Server with Portal for ArcGIS and enables the Mission Server role.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "portal": {
            "private_url": "https://portal.domain.com:7443/arcgis",
            "admin_username": "admin",
            "admin_password": "<password>",
            "root_cert": "",
            "root_cert_alias": ""
        },
        "mission_server": {
            "web_context_url": "https://domain.com/mission",
            "private_url": "https://domain.com/mission",
            "admin_username": "siteadmin",
            "admin_password": "<password>"
        }
    },
    "run_list": [
        "recipe[arcgis-mission::federation]"
    ]
}
```

### install_server

Installs ArcGIS Mission Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.3",
        "run_as_user": "arcgis",
        "mission_server": {
            "setup_archive": "/opt/software/esri/ArcGIS_Mission_Server_Linux_113_190339.tar.gz",
            "authorization_file": "/opt/software/esri/missionserver.prvc",
            "install_dir": "/home/arcgis",
            "server_directories_root": "/home/arcgis/mission/usr/directories",
            "config_store_connection_string": "/home/arcgis/mission/usr/directories/config-store",
            "configure_autostart": true,
            "install_system_requirements": true
        }
    },
    "run_list": [
        "recipe[arcgis-mission::install_server]"
    ]
}
```

### install_server_wa

Installs ArcGIS Web Adaptor for ArcGIS Mission Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.3",
        "run_as_user": "arcgis",
        "web_server": {
            "webapp_dir": "/opt/tomcat_arcgis/webapps"
        },
        "web_adaptor": {
            "install_dir": "/",
            "setup_archive": "/opt/software/esri/ArcGIS_Web_Adaptor_Java_Linux_113_%%BUILDNUM.tar.gz"
        },
        "mission_server": {
            "wa_name": "mission"
        }
    },
    "run_list": [
        "recipe[arcgis-mission::install_server_wa]"
    ]
}
```

### install_patches

Installs patches for ArcGIS Mission Server. The recipe installs patches from the patches folder specified by the arcgis.mission_server.patches attribute. The patch names may contain a wildcard '\*'. For example, "ArcGIS-1091-\*.msp" specifies all .msp patches that start with "ArcGIS-1091-".

Attributes used by the recipe:

```JSON
{
  "arcgis" : {
    "repository" : {
      "patches" : "%USERPROFILE%\\Software\\Esri\\patches"
    },
    "mission_server": {
      "patches": ["patch1.msp", "patch2.msp"]
    }
  },
  "run_list": [
    "recipe[arcgis-mission::install_patches]"
  ]
}
```

### server

Installs and configures ArcGIS Mission Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.3",
        "run_as_user": "arcgis",
        "mission_server": {
            "setup_archive": "/opt/software/esri/ArcGIS_Mission_Server_Linux_113_190339.tar.gz",
            "authorization_file": "/opt/software/esri/missionserver.prvc",
            "admin_username": "siteadmin",
            "admin_password": "<password>",
            "install_dir": "/home/arcgis",
            "directories_root": "/home/arcgis/mission/usr/directories",
            "config_store_connection_string": "/home/arcgis/mission/usr/config-store",
            "config_store_type": "FILESYSTEM",
            "configure_autostart": true,
            "install_system_requirements": true,
            "log_dir": "/home/arcgis/mission/usr/logs",
            "log_level": "WARNING",
            "max_log_file_age": "90",
            "system_properties": { }
        }
    },
    "run_list": [
        "recipe[arcgis-mission::server]"
    ]
}
```

### server_node

Joins additional machines to an ArcGIS Mission Server site.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.3",
        "run_as_user": "arcgis",
        "mission_server": {
            "setup_archive": "/opt/software/esri/ArcGIS_Mission_Server_Linux_113_190339.tar.gz",
            "authorization_file": "/opt/software/esri/missionserver.prvc",
            "admin_username": "siteadmin",
            "admin_password": "<password>",
            "install_dir": "/home/arcgis",
            "primary_server_url": "https://primary:20443/arcgis",
            "configure_autostart": true,
            "install_system_requirements": true,
            "log_dir": "/home/arcgis/mission/usr/logs"
        }
    },
    "run_list": [
        "recipe[arcgis-mission::server_node]"
    ]
}
```

### server_wa

Installs and configures ArcGIS Web Adaptor for ArcGIS Mission Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.3",
        "run_as_user": "arcgis",
        "web_server": {
            "webapp_dir": "/opt/tomcat_arcgis/webapps"
        },
        "web_adaptor": {
            "install_dir": "/",
            "setup_archive": "/opt/software/esri/ArcGIS_Web_Adaptor_Java_Linux_113_190319.tar.gz"
        },
        "mission_server": {
            "url": "https://hostname:20443",
            "wa_name": "mission",
            "wa_url": "https://hostname/mission",
            "admin_username": "siteadmin",
            "admin_password": "<password>"
        }
    },
    "run_list": [
        "recipe[arcgis-mission::server_wa]"
    ]
}
```

### uninstall_server

Uninstalls ArcGIS Mission Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.3",
        "run_as_user": "arcgis",
        "mission_server": {
            "install_dir": "/home/arcgis"
        }
    },
    "run_list": [
        "recipe[arcgis-mission::uninstall_server]"
    ]
}
```

### uninstall_server_wa

Uninstalls ArcGIS Web Adaptor for ArcGIS Mission Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.3",
        "run_as_user": "arcgis",
        "web_server": {
            "webapp_dir": "/opt/tomcat_arcgis/webapps"
        },
        "web_adaptor": {
            "install_dir": "/"
        },
        "mission_server": {
            "wa_name": "mission"
        }
    },
    "run_list": [
        "recipe[arcgis-mission::uninstall_server_wa]"
    ]
}
```

### unregister_server_wa

Unregisters all ArcGIS Web Adaptors from ArcGIS Mission Server Site.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "mission_server": {
      "url": "https://hostname:20443/arcgis",
      "admin_username": "siteadmin",
      "admin_password": "<password>"
    }
  },
  "run_list": [
    "recipe[arcgis-mission::unregister_server_wa]"
  ]
}
```
