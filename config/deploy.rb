# Capistrano Multistage Support
#set :default_stage, "staging"
#set :stages, %w(production staging)
#require 'capistrano/ext/multistage'

# Include Bundler Extensions
require "bundler/capistrano"

# Uncomment the following and edit 'USERNAME' if SSH key forwarding is required.
# Also, be sure to change id_rsa to antoher private key if you're not using the default id_rsa
# Last, be sure to ssh-add the key if you're not already specifing key+hostname in .ssh/config
# set :ssh_options, { :forward_agent => true, :keys => %w(/Users/USERNAME/.ssh/id_rsa) }

# Server Settings
# Comment this out if you're using Multistage support.
set :user, "deploy"
set :server_name, "stage01.c45935.blueboxgrid.com"
role :app, server_name
role :web, server_name
role :db,  server_name, :primary => true

# Application Settings
set :application, "one-ring"
set :deploy_to, "/home/#{user}/rails_apps/#{application}"
set :disable_path, "#{shared_path}/system/maintenance"

# Repo Settings
set :repository,  "git@github.com:bbg-deploy/one-ring.git"
set :scm, "git"
set :checkout, 'export'
set :copy_exclude, ".git/*"
set :deploy_via, :remote_cache

# General Settings
default_run_options[:pty] = true
default_environment["LANG"] = "en_US.UTF-8"
default_environment["LC_ALL"] = "en_US.UTF-8"
set :ssh_options, { :forward_agent => true }
set :keep_releases, 5
set :use_sudo, false

# Hooks
after "deploy", "deploy:cleanup"
after "deploy:update_code", "deploy:database_symlink"

namespace :deploy do
  task :database_symlink, :except => { :no_release => true } do
    run "rm -f #{release_path}/config/database.yml"
    run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  task :restart, :except => { :no_release => true } do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end

  task :start, :except => { :no_release => true } do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end
end

# Disable the built in disable command and setup some intelligence so we can have images.
namespace :deploy do
  namespace :web do
    desc "Disables the website by putting the maintenance page in place."
    task :disable, :except => { :no_release => true } do
      on_rollback { run "rm -f #{disable_path}/index.html" }
      run "cp #{disable_path}/index.disabled.html #{disable_path}/index.html"
    end

    desc "Enables the website by removing the maintenance file."
    task :enable, :except => { :no_release => true } do
        run "rm -f #{disable_path}/index.html"
    end

    desc "Copies your maintenance from public/maintenance to shared/system/maintenance."
    task :update_maintenance_page, :except => { :no_release => true } do
      run "rm -rf #{shared_path}/system/maintenance/; true"
      run "mkdir -p #{release_path}/public/maintenance"
      run "cp -r #{release_path}/public/maintenance #{shared_path}/system/"
    end
  end
end

