# arcgis-egdb

arcgis-egdb cookbook creates enterprise geodatabases in SQL Server or PostgreSQL DBMS and registers them with ArcGIS Server.

## Platforms

* Windows 7
* Windows 8 (8.1)
* Windows 10
* Windows Server 2008 (R2)
* Windows Server 2012 (R2)
* Windows Server 2016
* Ubuntu 14.04/16.04
* Rhel 6.5, 7.0

## Database Servers 

The cookbook was tested with:

* Amazon RDS for SQL Server
* Amazon RDS for PostgerSQL
* Amazon Aurora PostgerSQL-compatible

## Dependencies

The following cookbooks are required:

* arcgis-enterprise

The cookbook uses ArcPy to create and enable geodatabases. ArcPy is installed by ArcGIS Server setup.

ArcPy does not support creating databases in Amazon RDS database servers. The cookbook uses sqlcmd and pqsl utility for SQL Server and PostgreSQL database servers to create the databases. 'sqlcmd' and 'psql' recipes could be used to install these utilities. ArcGIS DataStore and Portal for ArcGIS include embedded PostgreSQl client with psql utility, that can be used by arcgis-egdb cookbook.

## Attributes

* `node['arcgis']['egdb']['engine']` = DB engine <nil|postgres|sqlserver-se>. Default DB engine is `nil`.
* `node['arcgis']['egdb']['endpoint']` = DB instance endpoint domain name. Default endpoint is `nil`.
* `node['arcgis']['egdb']['keycodes']` = Geodatabase license file path. Default path is `node['arcgis']['server']['keycodes']`.
* `node['arcgis']['egdb']['master_username']` = RDS DB instance master username. Default username is `EsriRDSAdmin`.
* `node['arcgis']['egdb']['master_password']` = RDS DB instance master user password. Default password is `nil`.
* `node['arcgis']['egdb']['db_username']` = Geodatabase username. Default username is `sde`.
* `node['arcgis']['egdb']['db_password']` = Geodatabase user password. Default password is `node['arcgis']['egdb']['master_password']`.
* `node['arcgis']['egdb']['postgresbin']` = Path to PostgreSQL client bin directory. Default path s `C:\Program Files\ArcGIS\DataStore\framework\runtime\pgsql\bin` on wondows and `/arcgis/datastore/framework/runtime/pgsql/bin` on Linux.
* `node['arcgis']['egdb']['connection_files_dir']` = Directory path for geodatabase connection files  created by the recipes. Default directory is `node['arcgis']['misc']['scripts_dir']/connection_files`.
* `node['arcgis']['egdb']['data_items']` = Array with properties of geodatabases. Default value is

  ```JSON
  [{
    "database" : "egdb",
    "data_item_path" : "/enterpriseDatabases/registeredDatabase",
    "connection_file": "C:\\chef\\msic_scripts\\connection_files\\RDS_egdb.sde",
    "is_managed" : true,
    "connection_type" : "shared"
  }]
  ```

## Recipes

### arcgis-egdb::default

Creates EGDBs and registers them with ArcGIS Server.

### arcgis-egdb::sql_alias

Creates EGDBHOST alias for SQL Server endpoint domain.

### arcgis-egdb::egdb_postgres

Creates EGDBs in PostgreSQL.

### arcgis-egdb::egdb_sqlserver

Creates EGDBs in SQL Server.

### arcgis-egdb::register_egdb

Registers EGDBs with ArcGIS Server.

### arcgis-egdb::sqlcmd

Installs sqlcmd utility used by SQL Server EGDB configuration scripts.


## Usage


```json
{
  "arcgis": {
    "version": "10.7",
    "server": {
      "private_url": "https://domain.com:6443/arcgis",
      "admin_username": "admin",
      "admin_password": "changeit"
    },
    "python": {
      "runtime_environment": "C:\\Python27\\ArcGISx6410.7"
    },
    "misc": {
      "scripts_dir": "C:\\chef\\misc_scripts"
    },
    "egdb": {
      "engine": "postgres",
      "endpoint": "xxx.cluster-yyy.us-east-2.rds.amazonaws.com",
      "keycodes": "C:\\Program Files\\ESRI\\License10.7\\sysgen\\keycodes",
      "master_username": "EsriRDSAdmin",
      "master_password": "changeit",
      "db_username": "sde",
      "db_password": "changeit",
      "connection_files_dir": "C:\\chef\\misc_scripts\\connection_files",
      "data_items": [{
        "database": "egdb",
        "data_item_path": "/enterpriseDatabases/registeredDatabase",
        "connection_file": "C:\\chef\\msic_scripts\\connection_files\\RDS_egdb.sde",
        "is_managed": true,
        "connection_type": "shared"
      }]
    }
  },
  "run_list": [
    "recipe[arcgis-egdb]"
  ]
}
```

See [wiki](https://github.com/Esri/arcgis-cookbook/wiki) pages for more information about using ArcGIS cookbooks.

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an [issue](https://github.com/Esri/arcgis-cookbook/issues).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

## Licensing

Copyright 2019 Esri

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

[](Esri Tags: ArcGIS GeoDatabase Server Chef Cookbook)
[](Esri Language: Ruby)
