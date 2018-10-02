actions :create_task_server_site_backup, :authorize_user,
        :create_webgis_backup_configuration, :create_task_webgis_backup,
        :create_task_backup_cleanup

def initialize(*args)
  super
  @action = :publish
end
