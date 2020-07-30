name             'arcgis-repository'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache-2.0'
description      'Downloads ArcGIS software setups from remote to local repositories'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.6.0'
chef_version     '>= 13.0', '< 15.0' if defined? chef_version

depends 's3_file', '~> 2.8'

supports 'windows'
supports 'ubuntu'
supports 'redhat'

recipe 'arcgis-repository::default', 'Downloads files from remote ArcGIS software repository to local repository.'
recipe 'arcgis-repository::s3files', 'Downloads files from ArcGIS software repository in S3 to local repository.'
recipe 'arcgis-repository::s3files2', 'Downloads files from ArcGIS software repository in S3 to local repository using AWS CLI Tools on Linux and AWS Tools for PowerShell on Windows.'

issues_url 'https://github.com/esri/arcgis-cookbook/issues'
source_url 'https://github.com/esri/arcgis-cookbook'
