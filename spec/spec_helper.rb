require 'rubygems'
require 'bundler/setup'

require "tzinfo"
require "i18n"
require 'active_support/core_ext/date/zones'
require 'active_support/core_ext/time/zones'
require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/time/calculations'
require 'business-hours'
require 'timecop'

RSpec.configure do |config|
  config.color_enabled = true
end