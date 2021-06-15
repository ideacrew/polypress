# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'aca_entities',  git:  'https://github.com/ideacrew/aca_entities.git', branch: 'fdsh'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'event_source',       git: "https://github.com/ideacrew/event_source.git", branch: "release_0.5.1"

gem 'database_cleaner',       '~> 1.7'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

gem 'dry-matcher',          '~> 0.8'
gem 'dry-monads',           '~> 1.3'
gem 'dry-struct',           '~> 1.3'
gem 'dry-transaction'
gem 'dry-types',            '~> 1.4'
gem 'dry-validation',       '~> 1.6'
gem 'mongoid',             '~> 7.2.1'
gem 'mongoid-locker'
gem 'wicked_pdf',               '~> 1.1.0'
gem 'wkhtmltopdf-binary-edge',  '~> 0.12.3.0'
gem 'combine_pdf',              '~> 1.0'
gem 'effective_datatables', path: './project_gems/effective_datatables-2.6.14'
gem 'prawn', :git => 'https://github.com/prawnpdf/prawn.git', :ref => '8028ca0cd2'
gem 'ckeditor',                 '~> 4.2.4'
gem 'roo',                      '~> 2.7.0'
gem 'config',                   '~> 2.0'
gem 'pundit',                   '~> 2.1.0'
gem 'devise'
gem 'jquery-rails',             '~> 4.3'
gem 'liquid'

group :development, :test do
  gem "capistrano", "~> 3.10", require: false
  gem "capistrano-rails", "~> 1.6", require: false
  gem "capistrano-bundler", "~> 2.0", require: false
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails',            '~> 4.0'
  gem 'shoulda-matchers',       '~> 3'
  gem 'yard'
end
gem 'pry-byebug'

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0', require: false
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'rubocop', '1.10.0'
  gem 'rubocop-git'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :production do
  gem 'eye',     '0.10.0'
  gem 'unicorn', '~> 4.8'
end
