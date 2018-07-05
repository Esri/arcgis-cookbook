default['download_setups_s3'].tap do |s3|
  case node['platform']
  when 'windows'
    #
    # The name of the ArcGIS GeoEvent s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['geoevent']['remote_filename'] = 'arcgis_geoevent.tar'

    #
    # Full remote path to ArcGIS GeoEvent s3 setup file. This is a compiled
    # attribute of specific bucket structure and +geoevent+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['geoevent']['remote_path'] = ::File.join(
      node['arcgis']['version'],
      node['download_setups_s3']['geoevent']['remote_filename']
      )

    #
    # The name of the ArcGIS GeoEvent setup file. This can differ based on
    # packaging. Setting this to the name of the 'exe' will skip the resource
    # for extracting the setup if it is packaged as an 'exe'.
    #
    s3['geoevent']['src_filename'] = 'arcgis_geoevent.tar'

    #
    # The local path to the ArcGIS GeoEvent setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['geoevent']['local_path'] = ::File.join(
      node['download_setups_s3']['base']['src_path'], 'GeoEvent',
      )

    #
    # Compiled attribute of +geoevent+local_path+ and +geoevent+src_filename+. This
    # attribute can be overriden to specify the full path to the local setup.
    s3['geoevent']['src_path'] = ::File.join(
      node['download_setups_s3']['geoevent']['local_path'],
      node['download_setups_s3']['geoevent']['src_filename']
      )
  else
    #
    # The name of the ArcGIS GeoEvent s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['geoevent']['remote_filename'] = 'arcgis_geoevent_linux.tar.gz'

    #
    # Full remote path to ArcGIS GeoEvent s3 setup file. This is a compiled
    # attribute of specific bucket structure and +geoevent+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['geoevent']['remote_path'] = ::File.join(
      node['arcgis']['version'],
      node['download_setups_s3']['geoevent']['remote_filename']
      )

    #
    # The name of the ArcGIS GeoEvent setup file.
    #
    s3['geoevent']['src_filename'] = 'arcgis_geoevent_linux.tar.gz'

    #
    # The local path to the ArcGIS GeoEvent setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['geoevent']['local_path'] = ::File.join(
      node['download_setups_s3']['base']['src_path'], 'geoevent',
      )

    #
    # Compiled attribute of +geoevent+local_path+ and +geoevent+src_filename+. This
    # attribute can be overriden to specify the full path to the local setup.
    s3['geoevent']['src_path'] = ::File.join(
      node['download_setups_s3']['geoevent']['local_path'],
      node['download_setups_s3']['geoevent']['src_filename']
      )
  end
end
