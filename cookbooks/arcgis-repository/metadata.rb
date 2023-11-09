name             'arcgis-repository'
maintainer       'Esri'
maintainer_email 'contracts@esri.com'
license          'Apache-2.0'
description      'Downloads ArcGIS software setups from remote to local repositories'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '4.2.0'
chef_version     '>= 14.0' if defined? chef_version

depends 's3_file', '~> 2.8'
depends 'nfs', '~> 2.6'

supports 'windows'
supports 'ubuntu'
supports 'oracle'
supports 'redhat'
supports 'centos'
supports 'suse'
supports 'rocky'
supports 'almalinux'

recipe 'arcgis-repository::aws_cli', 'Downloads and installs AWS CLI on the machine.'
recipe 'arcgis-repository::default', 'Downloads files from remote ArcGIS software repository to local repository.'
recipe 'arcgis-repository::files', 'Downloads files from ArcGIS software repository.'
recipe 'arcgis-repository::fileserver', 'Creates repository directory and a network share for it.'
recipe 'arcgis-repository::patches', 'Downloads patches for specific ArcGIS products and versions from ArcGIS software repository.'
recipe 'arcgis-repository::s3files', 'Downloads files from ArcGIS software repository in S3 to local repository.'
recipe 'arcgis-repository::s3files2', 'Downloads files from ArcGIS software repository in S3 to local repository using AWS CLI Tools on Linux and AWS Tools for PowerShell on Windows.'

issues_url 'https://github.com/esri/arcgis-cookbook/issues'
source_url 'https://github.com/esri/arcgis-cookbook'
