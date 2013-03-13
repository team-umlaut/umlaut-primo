require 'coveralls'
Coveralls.wear!
# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__) 
Rails.backtrace_cleaner.remove_silencers!
# Complete stack trace with deprecation warnings from rails
ActiveSupport::Deprecation.debug = true
it 
# VCR is used to 'record' HTTP interactions with
# third party services used in tests, and play em
# back. Useful for efficiency, also useful for
# testing code against API's that not everyone
# has access to -- the responses can be cached
# and re-used.
require 'vcr'
require 'webmock'

VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr_cassettes'
  # webmock needed for HTTPClient testing
  c.hook_into :webmock
  # c.debug_logger = $stderr
  c.filter_sensitive_data("primo.library.edu") { "bobcat.library.nyu.edu" }
  c.filter_sensitive_data("LIB01") { "NYU01" }
end
