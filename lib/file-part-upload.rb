require 'file_part_upload/mini_magick'
require 'file_part_upload/instance'
require 'file_part_upload/validate'
require 'file_part_upload/upload_file'
require 'file_part_upload/attach'
require 'file_part_upload/util'
require 'file_part_upload/error'
require 'file_part_upload/file_entity'
require 'file_part_upload/config'
require 'file_part_upload/controller_helper'

module FilePartUpload

  class << self
    attr_accessor :root, :base_path

    def config(&block)
      # 读取配置
      FilePartUpload::Config.config(&block)
    end

    def file_part_upload_config
      self.instance_variable_get(:@file_part_upload_config) || {}
    end
  end


end

if defined?(Rails)
  class Railtie < Rails::Railtie
    initializer "file_part_upload.setup_paths" do
      FilePartUpload.root = Rails.root.join(Rails.public_path).to_s
      FilePartUpload.base_path = ENV['RAILS_RELATIVE_URL_ROOT'] || '/'
    end
  end
end