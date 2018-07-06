default['download_setups_s3'].tap do |s3|
  case node['platform']
  when 'windows'
    #
    # The name of the ArcGIS LicenseManager s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['licensemanager']['remote_filename'] = 'licensemanager.tar'

    #
    # Full remote path to ArcGIS LicenseManager s3 setup file. This is a compiled
    # attribute of specific bucket structure and +licensemanager+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['licensemanager']['remote_path'] = ::File.join(
      node['arcgis']['version'],
      node['download_setups_s3']['licensemanager']['remote_filename']
      )

    #
    # The name of the ArcGIS LicenseManager setup file. This can differ based on
    # packaging. Setting this to the name of the 'exe' will skip the resource for
    # extracting the setup if it is packaged as an 'exe'.
    #
    s3['licensemanager']['src_filename'] = 'licensemanager.tar'

    #
    # The local path to the ArcGIS LicenseManager setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['licensemanager']['local_path'] = ::File.join(
      node['download_setups_s3']['base']['src_path'], 'LicenseManager',
      )

    #
    # Compiled attribute of +licensemanager+local_path+ and
    # +licensemanager+src_filename+. This attribute can be overriden to specify
    # the full path to the local setup.
    s3['licensemanager']['src_path'] = ::File.join(
      node['download_setups_s3']['licensemanager']['local_path'],
      node['download_setups_s3']['licensemanager']['src_filename']
      )
  else
    #
    # The name of the ArcGIS LicenseManager s3 setup file. This will change based on
    # current vs past releases due to differences in packaging.
    #
    s3['licensemanager']['remote_filename'] = 'licensemanager.tar.gz'

    #
    # Full remote path to ArcGIS LicenseManager s3 setup file. This is a compiled
    # attribute of specific bucket structure and +licensemanager+remote_filename+
    # attribute, but you can override and specify full path.
    #
    s3['licensemanager']['remote_path'] = ::File.join(
      node['arcgis']['version'],
      node['download_setups_s3']['licensemanager']['remote_filename']
      )

    #
    # The name of the ArcGIS LicenseManager setup file. This can differ based on
    # packaging. Setting this to the name of the 'exe' will skip the resource for
    # extracting the setup if it is packaged as an 'exe'.
    #
    s3['licensemanager']['src_filename'] = 'licensemanager.tar.gz'

    #
    # The local path to the ArcGIS LicenseManager setup. This attribute is used for
    # creating the path to and extraction of the setup.
    #
    s3['licensemanager']['local_path'] = ::File.join(
      node['download_setups_s3']['base']['src_path'], 'licensemanager',
      )

    #
    # Compiled attribute of +licensemanager+local_path+ and
    # +licensemanager+src_filename+. This attribute can be overriden to specify
    # the full path to the local setup.
    s3['licensemanager']['src_path'] = ::File.join(
      node['download_setups_s3']['licensemanager']['local_path'],
      node['download_setups_s3']['licensemanager']['src_filename']
      )
  end
end
