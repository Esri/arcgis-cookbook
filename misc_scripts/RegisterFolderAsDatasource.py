import arcpy

conn = sys.argv[1]
name = sys.argv[2]
server_path = sys.argv[3]

# check whether an additional publisher path has been provided
if (len(sys.argv) > 4):
    publisher_path = sys.argv[4]
else:
	publisher_path = ""

# check whether the folder to register is already register => if yes, delete the former registered folders
for item in arcpy.ListDataStoreItems(conn, "FOLDER"):
    current_name = item[0]
    if current_name == name:
        arcpy.RemoveDataStoreItem(conn, "FOLDER", name)

if  publisher_path == "":
    arcpy.AddDataStoreItem(conn, "FOLDER", name, server_path)
else:
    arcpy.AddDataStoreItem(conn, "FOLDER", name, server_path, publisher_path)