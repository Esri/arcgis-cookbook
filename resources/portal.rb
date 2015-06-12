actions :install, :authorize, :create_site, :register_server, :stop, :start

attribute :install_dir, :kind_of => String
attribute :setup, :kind_of => String
attribute :content_dir, :kind_of => String
attribute :run_as_user, :kind_of => String
attribute :run_as_password, :kind_of => String
attribute :authorization_file, :kind_of => String
attribute :authorization_file_version, :kind_of => String
attribute :portal_url, :kind_of => String
attribute :portal_local_url, :kind_of => String
attribute :username, :kind_of => String
attribute :password, :kind_of => String
attribute :email, :kind_of => String
attribute :full_name, :kind_of => String
attribute :description, :kind_of => String
attribute :security_question, :kind_of => String
attribute :security_question_answer, :kind_of => String
attribute :server_url, :kind_of => String
attribute :is_hosted, :kind_of => [TrueClass, FalseClass], :default => false

def initialize(*args)
  super
  @action = :install
end