require 'file_part_upload/instance'
require 'file_part_upload/upload_file'
require 'file_part_upload/attach'
require 'file_part_upload/util'
require 'file_part_upload/error'

module FilePartUpload

  class << self
    attr_accessor :root, :base_path, :rails_env_is_test
  end

  module Base
    extend ActiveSupport::Concern
    module ClassMethods
      def file_part_upload(config = {})
        self.attr_accessible  :attach,
                              :attach_file_name,
                              :attach_file_size

        self.class_variable_set(:@@file_part_upload_config, config) 
        self.send(:include, FilePartUpload::Instance) 
      end

      def file_part_upload_config
        self.class_variable_get(:@@file_part_upload_config)
      end
    end
  end

end

if defined?(Rails)
  class Railtie < Rails::Railtie
    initializer "file_part_upload.setup_paths" do
      FilePartUpload.root = Rails.root.join(Rails.public_path).to_s
      FilePartUpload.base_path = ENV['RAILS_RELATIVE_URL_ROOT'] || '/'
      if Rails.env == 'test'
        FilePartUpload.rails_env_is_test = true
      else
        FilePartUpload.rails_env_is_test = false
      end
    end
  end
end

ActiveRecord::Base.send :include, FilePartUpload::Base