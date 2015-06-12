actions :install, :configure 

attribute :setup, :kind_of => String
attribute :install_dir, :kind_of => String
attribute :data_dir, :kind_of => String
attribute :run_as_user, :kind_of => String
attribute :run_as_password, :kind_of => String
attribute :server_url, :kind_of => String
attribute :username, :kind_of => String
attribute :password, :kind_of => String

def initialize(*args)
  super
  @action = :install
end