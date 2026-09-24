# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require "shoulda/matchers"

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |file| require file }

module Features
  # Extend this module in spec/support/features/*.rb
end

RSpec.configure do |config|
  config.include Features, type: :feature
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  if Bullet.enable?
    config.before(:each) do
      Bullet.start_request
    end

    config.after(:each) do |example|
      # Controller specs do not render views, so Bullet can only report false
      # positives there (e.g. "avoid eager loading"); requests/features cover
      # the rendered templates where real N+1 queries surface.
      if Bullet.notification? && example.metadata[:type] != :controller
        Bullet.perform_out_of_channel_notifications
      end
      Bullet.end_request
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end