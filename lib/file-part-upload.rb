require 'file_part_upload/mini_magick'
require 'file_part_upload/office_methods'
require 'file_part_upload/instance'
require 'file_part_upload/validate'
require 'file_part_upload/upload_file'
require 'file_part_upload/attach'
require 'file_part_upload/util'
require 'file_part_upload/error'
require 'file_part_upload/file_entity'
require 'file_part_upload/config'
require 'file_part_upload/controller_helper'
require 'file_part_upload/office_helper'

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

# 引用 rails engine
require 'file_part_upload/engine'
