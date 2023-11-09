name 'arcgis-egdb'
maintainer 'Esri'
maintainer_email 'contracts@esri.com'
license 'Apache 2.0'
description 'Creates enterprise geodatabases in SQL Server or PostgreSQL DBMS and registers them with ArcGIS Server.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.1.1'
chef_version '>= 14.0' if defined? chef_version

depends    'arcgis-enterprise', '~> 4.2'

supports   'windows'
supports   'ubuntu'
supports   'redhat'
supports   'oracle'

recipe     'arcgis-egdb::default', 'Creates EGDBs in the specified DBMS and registers them with ArcGIS Server'
recipe     'arcgis-egdb::sql_alias', 'Creates EGDBHOST alias for SQL Server endpoint domain'
recipe     'arcgis-egdb::egdb_postgres', 'Creates EGDBs in PostgreSQL'
recipe     'arcgis-egdb::egdb_sqlserver', 'Creates EGDBs in SQL Server '
recipe     'arcgis-egdb::register_egdb', 'Registers EGDBs with ArcGIS Server'
recipe     'arcgis-egdb::sqlcmd', 'Installs Microsoft SQL Server ODBC drivers and command line utilities used by SQL Server EGDB configuration scripts'

issues_url 'https://github.com/Esri/arcgis-cookbook/issues' if respond_to?(:issues_url)
source_url 'https://github.com/Esri/arcgis-cookbook' if respond_to?(:source_url)
