require 'rails/generators/active_record'
require 'active_support/core_ext'
require 'erb'

module ActiveRecord
  module Generators
    class FilePartUploadGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_initializer
        migration_template "migration.rb", "db/migrate/create_file_part_upload.rb"
      end

    end
  end
end
