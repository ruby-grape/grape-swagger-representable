# frozen_string_literal: true

require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov::Formatter::LcovFormatter.config.single_report_path = 'coverage/lcov.info'
SimpleCov.formatter = ENV['CI'] ? SimpleCov::Formatter::LcovFormatter : SimpleCov::Formatter::HTMLFormatter

SimpleCov.configure do
  enable_coverage :branch
  add_filter '/spec/'
  track_files 'lib/**/*.rb'
end
