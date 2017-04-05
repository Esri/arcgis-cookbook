arcgis_enterprise_patches 'Install ArcGIS Patches' do
  only_if { !node['arcgis']['server']['product_code'].nil? }
  action :install
end