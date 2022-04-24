# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def self.context(name, &block)
      class_name = "Context_#{name.gsub(/[[:^word:]]+/, '_')}".to_sym
      const_set(class_name, Class.new(self, &block))
    end

    # Add more helper methods to be used by all tests here...
  end
end
