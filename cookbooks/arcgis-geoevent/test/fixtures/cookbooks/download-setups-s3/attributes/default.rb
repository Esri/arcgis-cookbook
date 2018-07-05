default['download_setups_s3'].tap do |s3|
  #
  # The bucket name of where the ArcGIS setups are stored.
  #
  s3['bucket'] = 'test-kitchen'

  #
  # The region of the bucket.
  #
  s3['region'] = 'us-west-1'

  #
  # The base path of where the ArcGIS setups will be downloaded to. This
  # attribute is based on the arcgis-enterprise [#{product}][setup] attribute.
  #
  case node['platform']
  when 'windows'
    s3['base']['src_path'] = ::File.join(
      node['arcgis']['repository']['setups'],
      'ArcGIS ' + node['arcgis']['version']
      )
  else
    s3['base']['src_path'] = ::File.join(
      node['arcgis']['repository']['setups'], node['arcgis']['version']
      )
  end

  #
  # The remote path of the authorization files. Combiled attribute of
  # +arcgis+version+ and default name of packaged authorication files. This can
  # be overridden to specify full path.
  #
  s3['auth_files']['remote_path'] = ::File.join(
    node['arcgis']['version'], 'auth_files.tar'
  )

  #
  # The path of the authorization files to be extracted to.
  #
  s3['auth_files']['local_path'] = '/auth_files'

  #
  # Compiled attribute of +auth_files+local_path+ and a default name of packaged
  # auth_files. This can be overriden to specify full path.
  #
  s3['auth_files']['src_path'] = ::File.join(
    node['download_setups_s3']['auth_files']['local_path'], 'auth_files.tar'
    )
end
