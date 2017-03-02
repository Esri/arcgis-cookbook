# esri-iis Cookbook

This cookbook enables IIS, installs features required by ArcGIS Web Adaptor (IIS), configures HTTPS, and starts IIS.

Requirements
------------

### Platforms
* Windows 7
* Windows 8 (8.1)
  - 8.1 requires .Net Framework 3.5 (See ms_dotnet cookbook README)
* Windows 10
  - requires .Net Framework 3.5 (See ms_dotnet cookbook README)
* Windows Server 2008 (R2)
* Windows Server 2012 (R2)

### Dependencies
The following cookbooks are required:
* openssl
* windows

## Attributes

* `node['arcgis']['iis']['domain_name']` = Domain name used for generating self-signed SSL certificate. By default, `<node FQDN>` is used.
* `node['arcgis']['iis']['keystore_file']` = Path to PKSC12 keystore file (.pfx) with server SSL certificate for IIS. Default value is `nil`.
* `node['arcgis']['iis']['keystore_password']` = Password for keystore file with server SSL certificate for IIS. Default value is `nil`.
* `node['arcgis']['iis']['web_site']` = IIS web site to configure. Dafault value is `Default Web Site`.
* `node['arcgis']['iis']['replace_https_binding']` = If false, the current HTTPS binding is not changed if it is already configured. Default value is `false`.
* `node['arcgis']['iis']['features']` = An array of windows features to be installed with IIS. Default value depends on Windows version.

## Usage

Include `esri-iis` in your node's `run_list`:

```json
{
  "arcgis": {
    "iis": {
      "domain_name": "domain.com",
      "keystore_file" : "C:\\domain_com.pfx",
      "keystore_password": "test",
      "web_site": "Default Web Site",
      "replace_https_binding": false
    }
  },
  "run_list": [
    "recipe[arcgis-iis]"
  ]
}
```

See [wiki](https://github.com/Esri/arcgis-cookbook/wiki) pages for more information about using ArcGIS cookbooks.

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an [issue](https://github.com/Esri/arcgis-cookbook/issues).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

Licensing
---------

Copyright 2017 Esri

Licensed under the Apache License, Version 2.0 (the "License");
You may not use this file except in compliance with the License.
You may obtain a copy of the License at
   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the license is available in the repository's [License.txt](https://github.com/Esri/arcgis-cookbook/blob/master/License.txt?raw=true) file.

[](Esri Tags: ArcGIS Web Adaptor IIS Chef Cookbook)
[](Esri Language: Ruby)