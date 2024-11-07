---
layout: default
title: "arcgis-video cookbook"
category: cookbooks
item: arcgis-video
version: 5.1.0
latest: true
---

# arcgis-video cookbook

This cookbook installs and configures ArcGIS Video Server.

## Supported ArcGIS Video Server versions

* 11.3
* 11.4

## Supported ArcGIS software

* ArcGIS Video Server

## Platforms

* Microsoft Windows Server 2016 Standard and Datacenter
* Microsoft Windows Server 2019 Standard and Datacenter
* Microsoft Windows Server 2022 Standard and Datacenter
* Ubuntu Server 20.04 LTS
* Red Hat Enterprise Linux Server 8
* SUSE Linux Enterprise Server 15
* Oracle Linux 8

## Dependencies

The following cookbooks are required:

* arcgis-enterprise
* arcgis-repository

## Attributes

* `node['arcgis']['video_server']['url']` = The ArcGIS Video Server URL. Default URL is `https://<FQDN of the machine>:21443`.
* `node['arcgis']['video_server']['wa_name']` = Name of the ArcGIS Web Adaptor used for the ArcGIS Video Server site. Default name is `video`.
* `node['arcgis']['video_server']['wa_url']` = The URL of the Web Adaptor used for the ArcGIS Video Server site. Default URL is `https://<FQDN of the machine>/<Video Server Web Adaptor name>`.
* `node['arcgis']['video_server']['domain_name']` = The ArcGIS Video Server site domain name. Default domain is FQDN of the machine.
* `node['arcgis']['video_server']['private_url']` = Private URL of the ArcGIS Video Server site. Default URL is `https://<FQDN of the machine>:21443/arcgis`.
* `node['arcgis']['video_server']['web_context_url']` = Web Context URL of the ArcGIS Video Server site. Default URL is `https://<FQDN of the machine>/<Video Server Web Adaptor name>`.
* `node['arcgis']['video_server']['authorization_file']` = The ArcGIS Video Server authorization file path.
* `node['arcgis']['video_server']['authorization_file_version']` = The ArcGIS Video Server authorization file version. Default value is `node['arcgis']['server']['authorization_file_version']`.
* `node['arcgis']['video_server']['authorization_options']` = Additional ArcGIS Video Server software authorization command line options. Default options are `''`.
* `node['arcgis']['video_server']['install_dir']` = The ArcGIS Video Server installation directory. By default, ArcGIS Video Server is installed to `%ProgramW6432%\ArcGIS\Video` on Windows machines and to `/home/arcgis` on Linux machines.
* `node['arcgis']['video_server']['directories_root']` = The root ArcGIS Video Server site's server directory location. The default value is `C:\arcgisvideoserver\directories` on Windows and `/<ArcGIS Video Server install directory>/videoserver/usr/directories` on Linux.
* `node['arcgis']['video_server']['config_store_connection_string']` = The configuration store location for the ArcGIS Video Server site. By default, the configuration store is created in the local directory `C:\arcgisvideoserver\config-store` on Windows and `/<install directory>/usr/config-store` on Linux.
* `node['arcgis']['video_server']['config_store_class_name']` = The ArcGIS Video Server configuration store persistence class name. Default value is `com.esri.arcgis.carbon.persistence.impl.filesystem.FSConfigPersistence`.
* `node['arcgis']['video_server']['log_level']` = ArcGIS Video Server log level. Default value is `WARNING`.
* `node['arcgis']['video_server']['log_dir']` = ArcGIS Video Server log directory. Default value is `C:\arcgisvideoserver\logs` on Windows and `/<install directory>/usr/logs` on Linux.
* `node['arcgis']['video_server']['max_log_file_age']` = ArcGIS Video Server maximum log file age. Default value is `90`.
* `node['arcgis']['video_server']['setup_archive']` = Path to the ArcGIS Video Server setup archive. Default value depends on `node['arcgis']['version']` attribute value.
* `node['arcgis']['video_server']['setup']` = The location of the ArcGIS Video Server setup executable. Default location is `%USERPROFILE%\Documents\ArcGIS11.4\VideoServer\Setup.exe` on Windows and `/opt/arcgis/11.4/VideoServer/Setup` on Linux.
* `node['arcgis']['video_server']['configure_autostart']` = If set to true, on Linux the Video Server is configured to start with the operating system. Default value is `true`.
* `node['arcgis']['video_server']['admin_username']` = Primary ArcGIS Video Server administrator user name. Default user name is `siteadmin`.
* `node['arcgis']['video_server']['admin_password']` = Primary ArcGIS Video Server administrator password. Default value is `nil`.
* `node['arcgis']['video_server']['primary_server_url']` = The URL of the existing ArcGIS Video Server site to join, in the format `https://videoserver.domain.com:21443/arcgis/admin`. Default URL `nil`.
* `node['arcgis']['video_server']['install_system_requirements']` = Enable system-level configuration for ArcGIS Video Server. Default value is `true`.
* `node['arcgis']['video_server']['ports']` = Ports to open for ArcGIS Video Server in the Windows firewall. Default is `21080, 21443`.
* `node['arcgis']['video_server']['system_properties']` = ArcGIS Video Server system properties. Default value is `{}`.
* `node['arcgis']['video_server']['hostname']` = Host name or IP address of the ArcGIS Video Server machine. Default value is  `''`.
* `node['arcgis']['video_server']['patches]` = File names of ArcGIS Video Server patches to install. Default value is `[]`.

## Recipes

### default

Calls arcgis-video::server recipe.

### federation

Federates ArcGIS Video Server with Portal for ArcGIS and enables the Video Server role.

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
        "video_server": {
            "web_context_url": "https://domain.com/video",
            "private_url": "https://domain.com/video",
            "admin_username": "siteadmin",
            "admin_password": "<password>"
        }
    },
    "run_list": [
        "recipe[arcgis-video::federation]"
    ]
}
```

### install_server

Installs ArcGIS Video Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.4",
        "run_as_user": "arcgis",
        "video_server": {
            "setup_archive": "/opt/software/esri/ArcGIS_Video_Server_Linux_113_190341.tar.gz",
            "authorization_file": "/opt/software/esri/videoserver.prvc",
            "install_dir": "/home/arcgis",
            "server_directories_root": "/home/arcgis/video/usr/directories",
            "config_store_connection_string": "/home/arcgis/video/usr/directories/config-store",
            "configure_autostart": true,
            "install_system_requirements": true
        }
    },
    "run_list": [
        "recipe[arcgis-video::install_server]"
    ]
}
```

### install_server_wa

Installs ArcGIS Web Adaptor for ArcGIS Video Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.4",
        "run_as_user": "arcgis",
        "web_server": {
            "webapp_dir": "/opt/tomcat_arcgis/webapps"
        },
        "web_adaptor": {
            "install_dir": "/",
            "setup_archive": "/opt/software/esri/ArcGIS_Web_Adaptor_Java_Linux_113_%%BUILDNUM.tar.gz"
        },
        "video_server": {
            "wa_name": "video"
        }
    },
    "run_list": [
        "recipe[arcgis-video::install_server_wa]"
    ]
}
```

### install_patches

Installs patches for ArcGIS Video Server. The recipe installs patches from the patches folder specified by the arcgis.video_server.patches attribute. The patch names may contain a wildcard '\*'. 

Attributes used by the recipe:

```JSON
{
  "arcgis" : {
    "repository" : {
      "patches" : "%USERPROFILE%\\Software\\Esri\\patches"
    },
    "video_server": {
      "patches": ["patch1.msp", "patch2.msp"]
    }
  },
  "run_list": [
    "recipe[arcgis-video::install_patches]"
  ]
}
```

### server

Installs and configures ArcGIS Video Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.4",
        "run_as_user": "arcgis",
        "video_server": {
            "setup_archive": "/opt/software/esri/ArcGIS_Video_Server_Linux_113_190341.tar.gz",
            "authorization_file": "/opt/software/esri/videoserver.prvc",
            "admin_username": "siteadmin",
            "admin_password": "<password>",
            "install_dir": "/home/arcgis",
            "directories_root": "/home/arcgis/video/usr/directories",
            "config_store_connection_string": "/home/arcgis/video/usr/config-store",
            "config_store_type": "FILESYSTEM",
            "configure_autostart": true,
            "install_system_requirements": true,
            "log_dir": "/home/arcgis/video/usr/logs",
            "log_level": "WARNING",
            "max_log_file_age": "90",
            "system_properties": { }
        }
    },
    "run_list": [
        "recipe[arcgis-video::server]"
    ]
}
```

### server_node

Joins additional machines to an ArcGIS Video Server site.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.4",
        "run_as_user": "arcgis",
        "video_server": {
            "setup_archive": "/opt/software/esri/ArcGIS_Video_Server_Linux_113_190341.tar.gz",
            "authorization_file": "/opt/software/esri/videoserver.prvc",
            "admin_username": "siteadmin",
            "admin_password": "<password>",
            "install_dir": "/home/arcgis",
            "primary_server_url": "https://primary:20443/arcgis",
            "configure_autostart": true,
            "install_system_requirements": true,
            "log_dir": "/home/arcgis/video/usr/logs"
        }
    },
    "run_list": [
        "recipe[arcgis-video::server_node]"
    ]
}
```

### server_wa

Installs and configures ArcGIS Web Adaptor for ArcGIS Video Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.4",
        "run_as_user": "arcgis",
        "web_server": {
            "webapp_dir": "/opt/tomcat_arcgis/webapps"
        },
        "web_adaptor": {
            "install_dir": "/",
            "setup_archive": "/opt/software/esri/ArcGIS_Web_Adaptor_Java_Linux_113_190319.tar.gz"
        },
        "video_server": {
            "url": "https://hostname:20443",
            "wa_name": "video",
            "wa_url": "https://hostname/video",
            "admin_username": "siteadmin",
            "admin_password": "<password>"
        }
    },
    "run_list": [
        "recipe[arcgis-video::server_wa]"
    ]
}
```

### uninstall_server

Uninstalls ArcGIS Video Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.4",
        "run_as_user": "arcgis",
        "video_server": {
            "install_dir": "/home/arcgis"
        }
    },
    "run_list": [
        "recipe[arcgis-video::uninstall_server]"
    ]
}
```

### uninstall_server_wa

Uninstalls ArcGIS Web Adaptor for ArcGIS Video Server.

Attributes used by the recipe:

```JSON
{
    "arcgis": {
        "version": "11.4",
        "run_as_user": "arcgis",
        "web_server": {
            "webapp_dir": "/opt/tomcat_arcgis/webapps"
        },
        "web_adaptor": {
            "install_dir": "/"
        },
        "video_server": {
            "wa_name": "video"
        }
    },
    "run_list": [
        "recipe[arcgis-video::uninstall_server_wa]"
    ]
}
```

### unregister_server_wa

Unregisters all ArcGIS Web Adaptors from ArcGIS Video Server Site.

Attributes used by the recipe:

```JSON
{
  "arcgis": {
    "video_server": {
      "url": "https://hostname:20443/arcgis",
      "admin_username": "siteadmin",
      "admin_password": "<password>"
    }
  },
  "run_list": [
    "recipe[arcgis-video::unregister_server_wa]"
  ]
}
```
