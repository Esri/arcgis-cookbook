actions :unpack, :install

attribute :setup_archive, :kind_of => String
attribute :setups_repo, :kind_of => String
attribute :setup, :kind_of => String
attribute :run_as_user, :kind_of => String

def initialize(*args)
  super
  @action = :publish
end