default['download_setups_s3'].tap do |s3|
  case node['platform']
  when 'windows'
    #
    # The name of the ArcGIS Desktop s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['desktop']['remote_filename'] = 'arcgis_desktop.tar'

    #
    # Full remote path to ArcGIS Desktop s3 setup file. This is a compiled
    # attribute of specific bucket structure and +desktop+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['desktop']['remote_path'] = ::File.join(
      node['arcgis']['version'],
      node['download_setups_s3']['desktop']['remote_filename']
      )

    #
    # The name of the ArcGIS Desktop setup file. This can differ based on
    # packaging. Setting this to the name of the 'exe' will skip the resource for
    # extracting the setup if it is packaged as an 'exe'.
    #
    s3['desktop']['src_filename'] = 'arcgis_desktop.tar'

    #
    # The local path to the ArcGIS Desktop setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['desktop']['local_path'] = ::File.join(
      node['download_setups_s3']['base']['src_path'], 'ArcGISDesktop',
      )

    #
    # Compiled attribute of +desktop+local_path+ and
    # +desktop+src_filename+. This attribute can be overriden to specify
    # the full path to the local setup.
    s3['desktop']['src_path'] = ::File.join(
      node['download_setups_s3']['desktop']['local_path'],
      node['download_setups_s3']['desktop']['src_filename']
      )
  end
end
