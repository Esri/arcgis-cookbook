---
layout: default
title: "esri-iis cookbook"
category: cookbooks
item: esri-iis
version: 0.2.0
latest: true
---

# esri-iis Cookbook

This cookbook enables IIS, installs features required by ArcGIS Web Adaptor (IIS), configures HTTPS, and starts IIS.

## Platforms

* Windows 7
* Windows 8 (8.1)
  - 8.1 requires .Net Framework 3.5 (See ms_dotnet cookbook README)
* Windows 10
  - requires .Net Framework 3.5 (See ms_dotnet cookbook README)
* Windows Server 2008 (R2)
* Windows Server 2012 (R2)
* Windows Server 2016
* Windows Server 2019
* Windows Server 2022

## Dependencies

The following cookbooks are required:
* openssl
* windows

## Attributes

* `node['arcgis']['iis']['domain_name']` = Domain name used for generating a self-signed SSL certificate. By default, `<node FQDN>` is used.
* `node['arcgis']['iis']['keystore_file']` = Path to PKSC12 keystore file (.pfx) with server SSL certificate for IIS. Default value is `nil`.
* `node['arcgis']['iis']['keystore_password']` = Password for keystore file with server SSL certificate for IIS. Default value is `nil`.
* `node['arcgis']['iis']['web_site']` = IIS web site to configure. Default value is `Default Web Site`.
* `node['arcgis']['iis']['replace_https_binding']` = If false, the current HTTPS binding is not changed if it is already configured. Default value is `false`.
* `node['arcgis']['iis']['features']` = An array of Windows features to be installed. Default value is `['Web-Server', 'Web-WebServer']`.

## Recipes

### default

Enables IIS features required by ArcGIS Web Adaptor (IIS) and configures HTTPS binding.

The default list of features depends on the Windows version.

```JSON
{
  "arcgis": {
    "iis": {
      "appid": "{00112233-4455-6677-8899-AABBCCDDEEFF}",
      "domain_name": "domain.com",
      "keystore_file": "C:\\chef\\cache\\domain.com.pfx",
      "keystore_password": "test",
      "web_site": "Default Web Site",
      "replace_https_binding": false,
      "features": [ "IIS-WebServerRole", "IIS-ISAPIFilter",
                    "IIS-ISAPIExtensions", "NetFx4Extended-ASPNET45", "IIS-NetFxExtensibility45",
                    "IIS-ASPNET45", "IIS-WebServerManagementTools", "IIS-ManagementConsole",
                    "IIS-ManagementService", "IIS-IIS6ManagementCompatibility",
                    "IIS-ManagementScriptingTools", "IIS-StaticContent", "IIS-BasicAuthentication",
                    "IIS-WindowsAuthentication", "IIS-Metabase", "IIS-WebSockets" 
      ]
    }
  },
  "run_list": [
    "recipe[esri-iis]"
  ]
}
```

If the specified keystore file does not exists, the recipe generates a self-signed SSL certificate for the specified domain.

### install

Enables IIS features required by ArcGIS Web Adaptor (IIS).

The default list of features depends on the Windows version.

```json
{
    "arcgis": {
      "iis": {
        "features": [ "IIS-WebServerRole", "IIS-ISAPIFilter",
                      "IIS-ISAPIExtensions", "NetFx4Extended-ASPNET45", "IIS-NetFxExtensibility45",
                      "IIS-ASPNET45", "IIS-WebServerManagementTools", "IIS-ManagementConsole",
                      "IIS-ManagementService", "IIS-IIS6ManagementCompatibility",
                      "IIS-ManagementScriptingTools", "IIS-StaticContent", "IIS-BasicAuthentication",
                      "IIS-WindowsAuthentication", "IIS-Metabase", "IIS-WebSockets" 
        ]
      }
    },
    "run_list": [
        "recipe[esri-iis::install]"
    ]
}
```
