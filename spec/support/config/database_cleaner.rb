# frozen_string_literal: true

require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :deletion

    # Only delete the "users" collection.
    # DatabaseCleaner[:mongoid].strategy = :deletion, { only: ["users"] }

    # Delete all collections except the "users" collection.
    # DatabaseCleaner[:mongoid].strategy = :deletion, { except: ["users"] }
  end

  config.around(:each) { |example| DatabaseCleaner.cleaning { example.run } }
end
