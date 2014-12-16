source 'https://rubygems.org'

ruby '2.1.5'

gem 'rails', '4.1.8'
gem 'pg'
gem 'gabba'
gem 'rest-client'
gem 'google-api-client', require: 'google/api_client'
gem 'dotenv-rails', groups: [:development, :test]

group :development do
  gem 'pry'
end

group :test do
  gem 'webmock'
end

group :production do
  gem "skylight"
  gem 'rails_12factor'
end
