# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in grape-swagger-representable.gemspec
gemspec

gem 'grape', ENV.fetch('GRAPE_VERSION', '>= 2.1')
gem 'grape-swagger', ENV.fetch('GRAPE_SWAGGER_VERSION', '>= 0')
gem 'json', '< 3' if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.2')
gem 'multi_json'
gem 'pry'
gem 'rack-test'
gem 'rake'
gem 'representable', ENV.fetch('REPRESENTABLE_VERSION', '>= 0')
gem 'rspec', '~> 3.0'
gem 'rubocop'
gem 'simplecov', require: false
gem 'simplecov-lcov', require: false
