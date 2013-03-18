# -*- encoding : utf-8 -*-
require 'coveralls'
Coveralls.wear!

require 'mysql2'
require 'active_support/all'
require 'active_record'
require 'file-part-upload'

require 'config/db_init'

require 'action_dispatch'

FilePartUpload.root = File.expand_path('../', __FILE__)
FilePartUpload.base_path = '/'
FilePartUpload.rails_env_is_test = false
