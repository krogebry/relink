#!/usr/bin/env ruby
require 'pp'
require 'json'
require 'mongo'
require 'logger'
require 'sinatra'
require 'colorize'

LIB_DIR = File.expand_path(File.join(File.dirname(__FILE__), 'libs'))

require format('%s/cache.rb', LIB_DIR)
require format('%s/linker.rb', LIB_DIR)

set :bind, '0.0.0.0'
set :port, ENV['PORT']
set :show_exceptions, false
set :raise_errors, true
enable :logging

begin
  LOG = Logger.new(STDERR)
  CACHE = DevOps::Cache.new()
  VERSION = File.read('VERSION')

  DB_HOSTNAME = ENV['DB_HOSTNAME'] ||= '127.0.0.1'

  MDB = Mongo::Client.new([format('%s:27017', DB_HOSTNAME)], :database => 'relink')

rescue => e
  LOG.fatal(format('Failed to create logger: %s', e))
  exit
end

require './routes.rb'
