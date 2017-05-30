source 'https://rubygems.org'


git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.2'
#gem 'rails', '~> 4.2.6'
gem 'sqlite3'
gem 'puma', '~> 3.0'
gem 'httparty'

gem 'sass-rails', '~> 5.0'
# Use jquery as the JavaScript library
gem 'jquery-rails'
#gem 'bootstrap-sass', '~> 3.2.0'
gem 'bootstrap_progressbar'

group :development, :test do
  gem 'byebug', platform: :mri
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'apipie-rails'

# Gemfile auth
gem 'sorcery'

# Ecommerce
gem 'coffee-rails'
gem 'activesupport', '~> 5.0.2'
#gem 'actioncable', github: 'rails/actioncable', branch: 'archive'
#gem 'activesupport', '~> 4.2.6'
gem 'spree', '~> 3.2.0'
gem 'spree_auth_devise', '~> 3.2.0.beta'
gem 'spree_gateway', '~> 3.2.0.beta'
