import arcpy, os, sys

server_url = sys.argv[1]
username = sys.argv[2]
password = sys.argv[3]
out_dir = sys.argv[4]
out_name = sys.argv[5]
out_folder_path = out_dir
out_full_path = os.path.join(out_dir, out_name)
staging_folder_path = out_dir
use_arcgis_desktop_staging_folder = False

# Check if connection file already exists => if yes, delete it
if os.path.exists(out_full_path):
    os.remove(out_full_path)

arcpy.mapping.CreateGISServerConnectionFile("ADMINISTER_GIS_SERVICES",
    out_folder_path,
    out_name,
    server_url,
    "ARCGIS_SERVER",
    use_arcgis_desktop_staging_folder,
    staging_folder_path,
    username,
    password,
    "SAVE_USERNAME")