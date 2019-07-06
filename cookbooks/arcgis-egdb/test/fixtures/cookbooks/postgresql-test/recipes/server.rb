postgresql_server_install 'My PostgreSQL Server install' do
  action :install
end

postgresql_server_install 'Setup my PostgreSQL 9.6 server' do
  password 'changeit'
  port 5433
  action :create
end
