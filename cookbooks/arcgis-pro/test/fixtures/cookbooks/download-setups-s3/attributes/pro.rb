default['download_setups_s3'].tap do |s3|
  case node['platform']
  when 'windows'
    #
    # The name of the ArcGIS Pro s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['pro']['remote_filename'] = 'arcgis_pro.tar'

    #
    # Full remote path to ArcGIS Pro s3 setup file. This is a compiled
    # attribute of specific bucket structure and +pro+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['pro']['remote_path'] = ::File.join(
      node['arcgis']['pro']['version'],
      node['download_setups_s3']['pro']['remote_filename']
      )

    #
    # The name of the ArcGIS Pro setup file. This can differ based on
    # packaging. Setting this to the name of the 'exe' will skip the resource for
    # extracting the setup if it is packaged as an 'exe'.
    #
    s3['pro']['src_filename'] = 'arcgis_pro.tar'

    #
    # The local path to the ArcGIS Pro setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['pro']['local_path'] = ::File.join(
      node['download_setups_s3']['base']['src_path'], 'Pro',
      )

    #
    # Compiled attribute of +pro+local_path+ and
    # +pro+src_filename+. This attribute can be overriden to specify
    # the full path to the local setup.
    s3['pro']['src_path'] = ::File.join(
      node['download_setups_s3']['pro']['local_path'],
      node['download_setups_s3']['pro']['src_filename']
      )
  end
end
