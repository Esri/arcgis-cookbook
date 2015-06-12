actions :install, :configure_with_server, :configure_with_portal 

attribute :install_dir, :kind_of => String
attribute :setup, :kind_of => String
attribute :instance_name, :kind_of => String
attribute :portal_url, :kind_of => String
attribute :portal_local_url, :kind_of => String
attribute :server_url, :kind_of => String
attribute :server_local_url, :kind_of => String
attribute :username, :kind_of => String
attribute :password, :kind_of => String

def initialize(*args)
  super
  @action = :install
end