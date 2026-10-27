# GrapeSwagger::Representable

[![Tests](https://github.com/ruby-grape/grape-swagger-representable/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/ruby-grape/grape-swagger-representable/actions/workflows/test.yml)
[![Coverage Status](https://coveralls.io/repos/github/ruby-grape/grape-swagger-representable/badge.svg?branch=master)](https://coveralls.io/github/ruby-grape/grape-swagger-representable?branch=master)

A [grape-swagger](https://github.com/ruby-grape/grape-swagger) adapter that documents [Representable](https://github.com/trailblazer/representable) decorators as Swagger response models.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape-swagger-representable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grape-swagger-representable

## Development

Requires Ruby 3.1 or newer, grape-swagger 2.x, and Representable 3.2 or newer within the 3.x series. After checking out the repo, run `bin/setup` to install dependencies. Run `bundle exec rake spec` for tests and `bundle exec rubocop` for lint. You can also run `bin/pry` for an interactive prompt.

GitHub Actions tests Ruby 3.1, 3.3, 3.4, and 4.0 across Grape 2, 3, and 4, including Representable 3.2 and the latest 3.x. Dependencies resolve from released gems rather than grape-swagger's development branch. Ruby 3.1 uses JSON 2.x for compatibility with its supported MultiJson versions.

To select dependencies locally, run, for example, `GRAPE_VERSION='~> 2.4' REPRESENTABLE_VERSION='~> 3.2.0' bundle update`, and set the same variables when running tests. `GRAPE_SWAGGER_VERSION` can select a particular supported grape-swagger release.

SimpleCov starts before loading the library and tracks all Ruby files under `lib/`. Local reports are written to `coverage/index.html`; CI uploads `coverage/lcov.info` to Coveralls using parallel matrix flags and a completion job.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ruby-grape/grape-swagger-representable.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
