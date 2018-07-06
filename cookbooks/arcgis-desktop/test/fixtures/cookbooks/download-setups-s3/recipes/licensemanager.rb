include_recipe 'download-setups-s3::auth_files'

directory node['download_setups_s3']['licensemanager']['local_path'] do
  recursive true
  action :create
end

aws_s3_file node['download_setups_s3']['licensemanager']['src_path'] do
  bucket node['download_setups_s3']['bucket']
  region node['download_setups_s3']['region']
  remote_path node['download_setups_s3']['licensemanager']['remote_path']
end

if node['platform'] == 'windows'
  seven_zip_archive 'extract licensemanager setup' do
    path node['download_setups_s3']['licensemanager']['local_path']
    source node['download_setups_s3']['licensemanager']['src_path']
    action :extract
    not_if { ::File.exist?(node['arcgis']['licensemanager']['setup']) }
  end
else
  tar_extract node['download_setups_s3']['licensemanager']['src_path'] do
    target_dir node['download_setups_s3']['licensemanager']['local_path']
    action :extract_local
    not_if { ::File.exist?(node['arcgis']['licensemanager']['setup']) }
  end
end
