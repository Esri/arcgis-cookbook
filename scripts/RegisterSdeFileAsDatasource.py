import arcpy

conn = sys.argv[1]
name = sys.argv[2]
sde_file = sys.argv[3]

# check whether the SDE to register is already register => if yes, delete the former registered SDE
for item in arcpy.ListDataStoreItems(conn, "DATABASE"):
    current_name = item[0]
    if current_name == name:
        arcpy.RemoveDataStoreItem(conn, "DATABASE", name)

arcpy.AddDataStoreItem(conn, "DATABASE", name, sde_file)