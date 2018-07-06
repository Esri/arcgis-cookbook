default['download_setups_s3'].tap do |s3|
  case node['platform']
  when 'windows'
    #
    # The name of the ArcGIS Server s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['server']['remote_filename'] = 'ArcGIS_Server.tar'

    #
    # Full remote path to ArcGIS Server s3 setup file. This is a compiled
    # attribute of specific bucket structure and +server+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['server']['remote_path'] = ::File.join(
      node['arcgis']['version'], 'arcgis_enterprise',
      node['download_setups_s3']['server']['remote_filename']
      )

    #
    # The name of the ArcGIS Server setup file. This can differ based on
    # packaging. Setting this to the name of the 'exe' will skip the resource
    # for extracting the setup if it is packaged as an 'exe'.
    #
    s3['server']['src_filename'] = 'ArcGIS_Server.tar'

    #
    # The local path to the ArcGIS Server setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['server']['local_path'] = ::File.join(
      node['download_setups_s3']['base']['src_path'], 'ArcGISServer',
      )

    #
    # Compiled attribute of +server+local_path+ and +server+src_filename+. This
    # attribute can be overriden to specify the full path to the local setup.
    s3['server']['src_path'] = ::File.join(
      node['download_setups_s3']['server']['local_path'],
      node['download_setups_s3']['server']['src_filename']
      )
  else
    #
    # The name of the ArcGIS Server s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['server']['remote_filename'] = 'ArcGIS_Server_Linux.tar.gz'

    #
    # Full remote path to ArcGIS Server s3 setup file. This is a compiled
    # attribute of specific bucket structure and +server+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['server']['remote_path'] = ::File.join(
      node['arcgis']['version'], 'arcgis_enterprise',
      node['download_setups_s3']['server']['remote_filename']
      )

    #
    # The name of the ArcGIS Server setup file.
    #
    s3['server']['src_filename'] = 'ArcGIS_Server_Linux.tar.gz'

    #
    # The local path to the ArcGIS Server setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['server']['local_path'] = ::File.join(
      node['download_setups_s3']['base']['src_path'], 'ArcGISServer',
      )

    #
    # Compiled attribute of +server+local_path+ and +server+src_filename+. This
    # attribute can be overriden to specify the full path to the local setup.
    s3['server']['src_path'] = ::File.join(
      node['download_setups_s3']['server']['local_path'],
      node['download_setups_s3']['server']['src_filename']
      )
  end
end
