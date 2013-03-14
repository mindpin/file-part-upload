require 'file_part_upload/instance'
require 'file_part_upload/upload_file'
require 'file_part_upload/attach'
require 'file_part_upload/util'

module FilePartUpload

  class << self
    attr_accessor :root, :base_path
  end

  module Base
    extend ActiveSupport::Concern
    module ClassMethods
      def file_part_upload
        self.send(:include, FilePartUpload::Instance) 
      end
    end
  end

end

if defined?(Rails)
  class Railtie < Rails::Railtie
    initializer "file_part_upload.setup_paths" do
      FilePartUpload.root = Rails.root.join(Rails.public_path).to_s 
      FilePartUpload.base_path = ENV['RAILS_RELATIVE_URL_ROOT'] 
    end
  end
end

ActiveRecord::Base.send :include, FilePartUpload::Base