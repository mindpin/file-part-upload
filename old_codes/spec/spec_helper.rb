# -*- coding: utf-8 -*-
require "bundler"
Bundler.setup(:default)
require 'active_support/dependencies/autoload'
require 'mongoid'
ENV['RACK_ENV'] = 'test'
Mongoid.load!(File.expand_path("../mongoid.yml",__FILE__))
require 'action_dispatch'
require "./lib/file-part-upload"
Bundler.require(:test)

RSpec.configure do |config|

  config.before :each do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:mongoid].start
  end

  config.after :each do
    DatabaseCleaner[:mongoid].clean
  end
end

FilePartUpload.root = File.expand_path('../', __FILE__)
FilePartUpload.base_path = '/'
