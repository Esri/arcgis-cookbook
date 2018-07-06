include_attribute 'download-setups-s3::default'

default['download_setups_s3'].tap do |s3|
  case node['platform']
  when 'windows'
    #
    # The name of the ArcGIS DataStore s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['data_store']['remote_filename'] = 'ArcGIS_DataStore.tar'

    #
    # Full remote path to ArcGIS DataStore s3 setup file. This is a compiled
    # attribute of specific bucket structure and +data_store+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['data_store']['remote_path'] = ::File.join(
      node['arcgis']['version'], 'arcgis_enterprise',
      node['download_setups_s3']['data_store']['remote_filename']
      )

    #
    # The name of the ArcGIS DataStore setup file. This can differ based on
    # packaging. Setting this to the name of the 'exe' will skip the resource for
    # extracting the setup if it is packaged as an 'exe'.
    #
    s3['data_store']['src_filename'] = 'ArcGIS_DataStore.tar'

    #
    # The local path to the ArcGIS DataStore setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['data_store']['local_path'] = ::File.join(
      node['download_setups_s3']['base']['src_path'], 'ArcGISDataStore',
      )

    #
    # Compiled attribute of +data_store+local_path+ and
    # +data_store+src_filename+. This attribute can be overriden to specify
    # the full path to the local setup.
    s3['data_store']['src_path'] = ::File.join(
      node['download_setups_s3']['data_store']['local_path'],
      node['download_setups_s3']['data_store']['src_filename']
      )
  else
    #
    # The name of the ArcGIS DataStore s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['data_store']['remote_filename'] = 'ArcGIS_DataStore_Linux.tar.gz'

    #
    # Full remote path to ArcGIS DataStore s3 setup file. This is a compiled
    # attribute of specific bucket structure and +data_store+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['data_store']['remote_path'] = ::File.join(
      node['arcgis']['version'], 'arcgis_enterprise',
      node['download_setups_s3']['data_store']['remote_filename']
      )

    #
    # The name of the ArcGIS DataStore setup file. This can differ based on
    # packaging. Setting this to the name of the 'exe' will skip the resource for
    # extracting the setup if it is packaged as an 'exe'.
    #
    s3['data_store']['src_filename'] = 'ArcGIS_DataStore_Linux.tar.gz'

    #
    # The local path to the ArcGIS DataStore setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['data_store']['local_path'] = ::File.join(
      node['download_setups_s3']['base']['src_path'], 'ArcGISDataStore_Linux',
      )

    #
    # Compiled attribute of +data_store+local_path+ and
    # +data_store+src_filename+. This attribute can be overriden to specify
    # the full path to the local setup.
    s3['data_store']['src_path'] = ::File.join(
      node['download_setups_s3']['data_store']['local_path'],
      node['download_setups_s3']['data_store']['src_filename']
      )
  end
end
