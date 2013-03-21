set :server_name, "stage01.c45935.blueboxgrid.com"
role :app, server_name
role :web, server_name
role :db,  server_name, :primary => true
