actions :install, :authorize, :create_site, :enable_ssl, :register_database, :federate 

attribute :setup, :kind_of => String
attribute :install_dir, :kind_of => String
attribute :python_dir, :kind_of => String
attribute :run_as_user, :kind_of => String
attribute :run_as_password, :kind_of => String
attribute :server_url, :kind_of => String
attribute :server_local_url, :kind_of => String
attribute :server_id, :kind_of => String
attribute :secret_key, :kind_of => String
attribute :portal_url, :kind_of => String
attribute :portal_username, :kind_of => String
attribute :portal_password, :kind_of => String
attribute :username, :kind_of => String
attribute :password, :kind_of => String
attribute :server_directories_root, :kind_of => String
attribute :authorization_file, :kind_of => String
attribute :authorization_file_version, :kind_of => String
attribute :data_item_path, :kind_of => String
attribute :connection_string, :kind_of => String
attribute :is_managed, :kind_of => [TrueClass, FalseClass], :default => false

def initialize(*args)
  super
  @action = :install
end