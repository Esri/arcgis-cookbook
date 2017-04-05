include_attribute 'arcgis-enterprise::server'

default['arcgis']['misc']['script_directory'] = "C:\\Chef\\scripts"

case node['arcgis']['version']
when '10.5'
  default['arcgis']['python']['python_runtime_environment'] = File.join(node['arcgis']['python']['install_dir'], "ArcGISx6410.5")
when '10.4.1'
  default['arcgis']['python']['python_runtime_environment'] = File.join(node['arcgis']['python']['install_dir'], "ArcGISx6410.4")
when '10.4'
  default['arcgis']['python']['python_runtime_environment'] = File.join(node['arcgis']['python']['install_dir'], "ArcGISx6410.4")
else
  throw 'Unsupported ArcGIS version'
end