actions :enable, :configure_https, :start

attribute :keystore_file, :kind_of => String
attribute :keystore_password, :kind_of => String
attribute :certificate_hash, :kind_of => String

def initialize(*args)
  super
  @action = :enable
end