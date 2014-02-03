#[TODO_CR] Displaying some duplicate gems warning while doing bundle install
# Gemfile lists the gem capybara (~> 2.1) and ffaker (>= 0) more than once.

source 'https://rubygems.org'

gem 'json'
gem 'mysql2'
gem 'multi_json', '1.2.0'
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2'
  gem 'coffee-rails', '~> 3.2'
end

group :test do
  gem 'rspec-rails', '~> 2.12.0'
  gem 'factory_girl_rails', '~> 4.2.1'
  gem 'email_spec', '~> 1.2.1'

  gem 'ffaker'
  gem 'shoulda-matchers', '~> 2.4.0'
  gem 'capybara', '~> 2.1'
  gem 'database_cleaner', '0.9.1'
  # gem 'selenium-webdriver', '2.32.0'
  gem 'launchy'
 # gem 'debugger'
end

gem 'spree', github: 'spree/spree', branch: '2-0-stable'

# Provides basic authentication functionality for testing parts of your engine
gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: '2-0-stable'

gemspec