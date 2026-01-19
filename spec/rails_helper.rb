require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'shoulda/matchers'

# Support 파일 로드
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Shoulda Matchers 설정
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_path = [Rails.root.join('spec/fixtures')]
  
  # Database Cleaner 사용
  config.use_transactional_fixtures = false
  
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end