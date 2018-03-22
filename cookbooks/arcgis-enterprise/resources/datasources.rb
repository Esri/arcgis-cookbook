actions :create_ags_connection_file, :delete_ags_connection_file,
        :create_folder, :share_folder, :register_folder,
        :register_sde_files, :register_sde_files_from_folder

attribute :admin_user, :kind_of => String
attribute :admin_password, :kind_of => String
attribute :folder, :kind_of => Hash
attribute :authorize_arcgis_service_account, :kind_of => [TrueClass, FalseClass], :default => false
attribute :publish_with_alternative_path, :kind_of => [TrueClass, FalseClass], :default => false
attribute :publish_with_fqdn, :kind_of => [TrueClass, FalseClass], :default => false
attribute :publish_with_hostname, :kind_of => [TrueClass, FalseClass], :default => false
        
def initialize(*args)
  super
  @action = :publish
end
