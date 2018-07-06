include_recipe 'seven_zip' if node['platform'] == 'windows'

directory node['download_setups_s3']['auth_files']['local_path'] do
  recursive true
  action :create
end

aws_s3_file node['download_setups_s3']['auth_files']['src_path'] do
  bucket node['download_setups_s3']['bucket']
  region node['download_setups_s3']['region']
  remote_path node['download_setups_s3']['auth_files']['remote_path']
  if node['platform'] == 'windows'
    notifies :extract,
             'seven_zip_archive[extract authorization files]',
             :immediately
  else
    notifies :extract_local,
             "tar_extract[#{node['download_setups_s3']['auth_files']['src_path']}]",
             :immediately
  end
end

seven_zip_archive 'extract authorization files' do
  path node['download_setups_s3']['auth_files']['local_path']
  source node['download_setups_s3']['auth_files']['src_path']
  action :nothing
end

tar_extract node['download_setups_s3']['auth_files']['src_path'] do
  target_dir node['download_setups_s3']['auth_files']['local_path']
  compress_char ''
  action :nothing
  only_if { true } # bug in tar cookbook where action :nothing is triggered.
end
