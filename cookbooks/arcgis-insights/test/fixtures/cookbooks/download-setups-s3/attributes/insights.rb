default['download_setups_s3'].tap do |s3|
  case node['platform']
  when 'windows'
    #
    # The name of the Insights for ArcGIS  s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['insights']['remote_filename'] = 'insights_for_arcgis.tar'

    #
    # Full remote path to Insights for ArcGIS  s3 setup file. This is a compiled
    # attribute of specific bucket structure and +insights+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['insights']['remote_path'] = ::File.join(
      node['arcgis']['insights']['version'],
      node['download_setups_s3']['insights']['remote_filename']
      )

    #
    # The name of the Insights for ArcGIS  setup file. This can differ based on
    # packaging. Setting this to the name of the 'exe' will skip the resource
    # for extracting the setup if it is packaged as an 'exe'.
    #
    s3['insights']['src_filename'] = 'insights_for_arcgis.tar'

    #
    # The local path to the Insights for ArcGIS  setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['insights']['local_path'] = ::File.join(
      node['download_setups_s3']['insights']['base']['src_path'], 'Insights',
      )

    #
    # Compiled attribute of +insights+local_path+ and
    # +insights+src_filename+. This attribute can be overriden to specify
    # the full path to the local setup.
    s3['insights']['src_path'] = ::File.join(
      node['download_setups_s3']['insights']['local_path'],
      node['download_setups_s3']['insights']['src_filename']
      )
  else
    #
    # The name of the Insights for ArcGIS  s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['insights']['remote_filename'] = 'insights_for_arcgis.tar.gz'

    #
    # Full remote path to Insights for ArcGIS  s3 setup file. This is a compiled
    # attribute of specific bucket structure and +insights+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['insights']['remote_path'] = ::File.join(
      node['arcgis']['insights']['version'],
      node['download_setups_s3']['insights']['remote_filename']
      )

    #
    # The name of the Insights for ArcGIS  setup file.
    #
    s3['insights']['src_filename'] = 'insights_for_arcgis.tar.gz'

    #
    # The local path to the Insights for ArcGIS  setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['insights']['local_path'] = ::File.join(
      node['download_setups_s3']['insights']['base']['src_path'], 'Insights',
      )

    #
    # Compiled attribute of +insights+local_path+ and
    # +insights+src_filename+. This attribute can be overriden to specify
    # the full path to the local setup.
    s3['insights']['src_path'] = ::File.join(
      node['download_setups_s3']['insights']['local_path'],
      node['download_setups_s3']['insights']['src_filename']
      )
  end
end
