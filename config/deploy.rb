# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "trunk"
set :repo_url, "https://github.com/ideacrew/polypress.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/deployments/polypress"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"
set :linked_files, (fetch(:linked_files, []) | ['config/mongoid.yml', 'config/initializers/devise.rb', "config/environments/production.rb"])

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/sockets", "public/sbc"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :assets do
  desc "Kill all the assets"
  task :refresh do
    on roles(:web) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute("cd #{release_path} && rm -rf node_modules && rm -f package-lock.json")
          execute("cd #{release_path} && nvm use 10 && yarn install")
          execute :rake, "assets:clobber"
          execute("cd #{release_path} && nvm use 10 && RAILS_ENV=production NODE_ENV=production bundle exec rake assets:precompile")
        end
      end
    end
  end
end
after "deploy:updated", "assets:refresh"