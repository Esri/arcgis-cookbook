default['download_setups_s3'].tap do |s3|
  case node['platform']
  when 'windows'
    #
    # The name of the ArcGIS WebAdaptor s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['web_adaptor']['remote_filename'] = 'ArcGIS_WebAdaptorIIS.tar'

    #
    # Full remote path to ArcGIS WebAdaptor s3 setup file. This is a compiled
    # attribute of specific bucket structure and +web_adaptor+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['web_adaptor']['remote_path'] = ::File.join(
      node['arcgis']['version'], 'arcgis_enterprise',
      node['download_setups_s3']['web_adaptor']['remote_filename']
      )

    #
    # The name of the ArcGIS WebAdaptor setup file. This can differ based on
    # packaging. Setting this to the name of the 'exe' will skip the resource
    # for extracting the setup if it is packaged as an 'exe'.
    #
    s3['web_adaptor']['src_filename'] = 'ArcGIS_WebAdaptorIIS.tar'

    #
    # The local path to the ArcGIS WebAdaptor setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['web_adaptor']['local_path'] = ::File.join(
      node['download_setups_s3']['base']['src_path'], 'WebAdaptorIIS',
      )

    #
    # Compiled attribute of +web_adaptor+local_path+ and
    # +web_adaptor+src_filename+. This attribute can be overriden to specify
    # the full path to the local setup.
    s3['web_adaptor']['src_path'] = ::File.join(
      node['download_setups_s3']['web_adaptor']['local_path'],
      node['download_setups_s3']['web_adaptor']['src_filename']
      )
  else
    #
    # The name of the ArcGIS WebAdaptor s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['web_adaptor']['remote_filename'] = 'ArcGIS_WebAdaptorJava_Linux.tar.gz'

    #
    # Full remote path to ArcGIS WebAdaptor s3 setup file. This is a compiled
    # attribute of specific bucket structure and +web_adaptor+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['web_adaptor']['remote_path'] = ::File.join(
      node['arcgis']['version'], 'arcgis_enterprise',
      node['download_setups_s3']['web_adaptor']['remote_filename']
      )

    #
    # The name of the ArcGIS WebAdaptor setup file.
    #
    s3['web_adaptor']['src_filename'] = 'ArcGIS_WebAdaptorJava_Linux.tar.gz'

    #
    # The local path to the ArcGIS WebAdaptor setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['web_adaptor']['local_path'] = ::File.join(
      node['download_setups_s3']['base']['src_path'], 'WebAdaptor',
      )

    #
    # Compiled attribute of +web_adaptor+local_path+ and
    # +web_adaptor+src_filename+. This attribute can be overriden to specify
    # the full path to the local setup.
    s3['web_adaptor']['src_path'] = ::File.join(
      node['download_setups_s3']['web_adaptor']['local_path'],
      node['download_setups_s3']['web_adaptor']['src_filename']
      )
  end
end
