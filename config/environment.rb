require 'dotenv'
require_relative '../lib/logging'

Dotenv.load('.env')

# Setup the logging
LOG_TO = ENV['LOG_TO']
DEBUG = ENV['DEBUG'].to_s.casecmp('true').zero?
SimplePG.log = Logger.new(LOG_TO.to_s.empty? ? STDOUT : LOG_TO)
SimplePG.log.level = DEBUG ? Logger::DEBUG : Logger::INFO
