default['download_setups_s3'].tap do |s3|
  case node['platform']
  when 'windows'
    #
    # The name of the Portal for ArcGIS s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['portal']['remote_filename'] = 'Portal_for_ArcGIS.tar'

    #
    # Full remote path to Portal for ArcGIS s3 setup file. This is a compiled
    # attribute of specific bucket structure and +portal+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['portal']['remote_path'] = ::File.join(
      node['arcgis']['version'], 'arcgis_enterprise',
      node['download_setups_s3']['portal']['remote_filename']
      )

    #
    # The name of the Portal for ArcGIS setup file. This can differ based on
    # packaging. Setting this to the name of the 'exe' will skip the resource
    # for extracting the setup if it is packaged as an 'exe'.
    #
    s3['portal']['src_filename'] = 'Portal_for_ArcGIS.tar'

    #
    # The local path to the Portal for ArcGIS setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['portal']['local_path'] = ::File.join(
      node['download_setups_s3']['base']['src_path'], 'PortalForArcGIS',
      )

    #
    # Compiled attribute of +portal+local_path+ and +portal+src_filename+. This
    # attribute can be overriden to specify the full path to the local setup.
    s3['portal']['src_path'] = ::File.join(
      node['download_setups_s3']['portal']['local_path'],
      node['download_setups_s3']['portal']['src_filename']
      )
  else
    #
    # The name of the Portal for ArcGIS s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['portal']['remote_filename'] = 'Portal_for_ArcGIS_Linux.tar.gz'

    #
    # Full remote path to Portal for ArcGIS s3 setup file. This is a compiled
    # attribute of specific bucket structure and +portal+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['portal']['remote_path'] = ::File.join(
      node['arcgis']['version'], 'arcgis_enterprise',
      node['download_setups_s3']['portal']['remote_filename']
      )

    #
    # The name of the Portal for ArcGIS setup file.
    #
    s3['portal']['src_filename'] = 'Portal_for_ArcGIS_Linux.tar.gz'

    #
    # The local path to the Portal for ArcGIS setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['portal']['local_path'] = ::File.join(
      node['download_setups_s3']['base']['src_path'], 'PortalForArcGIS',
      )

    #
    # Compiled attribute of +portal+local_path+ and +portal+src_filename+. This
    # attribute can be overriden to specify the full path to the local setup.
    s3['portal']['src_path'] = ::File.join(
      node['download_setups_s3']['portal']['local_path'],
      node['download_setups_s3']['portal']['src_filename']
      )
  end
end
