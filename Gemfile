source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in active_house.gemspec
gemspec

gem 'activemodel', ENV['RAILS_VERSION'], require: false
gem 'activesupport', ENV['RAILS_VERSION'], require: false

group :test do
  gem 'minitest', '~> 5.0', require: false
  gem 'rake', '~> 10.0', require: false
  gem 'rubocop', '0.58.1', require: false
  gem 'webmock', require: false
end
