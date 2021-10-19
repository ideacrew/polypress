# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.3'

gem 'aca_entities', git: 'https://github.com/ideacrew/aca_entities.git', branch: 'release_0.10.0'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

gem 'ckeditor', '~> 4.2.4'
gem 'combine_pdf', '~> 1.0'
gem 'config', '~> 2.0' # Deprecate for Resource Registry

gem 'devise', '~> 4.8'

gem 'dry-matcher', '~> 0.8'
gem 'dry-monads', '~> 1.3'
gem 'dry-schema', '~> 1.6'
gem 'dry-struct', '~> 1.4'
gem 'dry-transaction', '~> 0.13'
gem 'dry-types', '~> 1.5'
gem 'dry-validation', '~> 1.6'

gem 'effective_datatables', path: './project_gems/effective_datatables-2.6.14'

gem 'event_source',
    git: 'https://github.com/ideacrew/event_source.git',
    branch: 'release_0.5.5'

gem 'httparty', '~> 0.16'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
gem 'jquery-rails', '~> 4.3'
gem 'jquery-ui-rails'

# Had to clone to make nested search work in where filter
gem 'liquid', path: './project_gems/liquid-5.0.1'

gem 'mongoid', '~> 7.3.3'
gem 'mongoid-locker'

gem 'prawn', git: 'https://github.com/prawnpdf/prawn.git', ref: '8028ca0cd2'
gem 'pundit', '~> 2.1.0'

gem 'puma', '~> 5.0'
# Use SCSS for stylesheets

gem 'rails', '~> 6.1.4'

# Use Puma as the app server
gem 'resource_registry',
    git: 'https://github.com/ideacrew/resource_registry.git',
    branch: 'trunk'
# gem 'resource_registry',  path: '../resource_registry'

gem 'roo', '~> 2.7.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'sass-rails', '>= 6'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

gem 'webpacker', '~> 5.0'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'wicked_pdf', '~> 2.1'
gem 'wkhtmltopdf-binary-edge', '~> 0.12.3.0'

group :development, :test do
  # gem "capistrano", "~> 3.10", require: false
  # gem "capistrano-rails", "~> 1.6", require: false
  # gem "capistrano-bundler", "~> 2.0", require: false
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'database_cleaner-mongoid'
  gem 'factory_bot_rails'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 5.0'
  gem 'shoulda-matchers', '~> 3'
  gem 'yard'
end

group :development do
  gem 'listen', '~> 3.3'

  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rake'
  gem 'rubocop-rspec'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
end

group :production do
  gem 'eye', '0.10.0'
  gem 'unicorn', '~> 4.8'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
