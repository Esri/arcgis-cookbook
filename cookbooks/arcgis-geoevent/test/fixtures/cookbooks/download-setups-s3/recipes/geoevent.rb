include_recipe 'download-setups-s3::auth_files'

directory node['download_setups_s3']['geoevent']['local_path'] do
  recursive true
  action :create
end

aws_s3_file node['download_setups_s3']['geoevent']['src_path'] do
  bucket node['download_setups_s3']['bucket']
  region node['download_setups_s3']['region']
  remote_path node['download_setups_s3']['geoevent']['remote_path']
end

if node['platform'] == 'windows'
  seven_zip_archive 'extract geoevent setup' do
    path node['download_setups_s3']['geoevent']['local_path']
    source node['download_setups_s3']['geoevent']['src_path']
    action :extract
    not_if { ::File.exist?(node['arcgis']['geoevent']['setup']) }
  end
else
  tar_extract node['download_setups_s3']['geoevent']['src_path'] do
    target_dir node['download_setups_s3']['geoevent']['local_path']
    action :extract_local
    not_if { ::File.exist?(node['arcgis']['geoevent']['setup']) }
  end
end
