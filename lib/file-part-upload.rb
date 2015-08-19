module FilePartUpload

  class << self
    attr_accessor :root, :base_path

    def config(&block)
      # 读取配置
      FilePartUpload::Config.config(&block)

      # 根据 mode 加载不同的模块
      FilePartUpload::ModuleLoader.load_by_mode!
    end

    def file_part_upload_config
      self.instance_variable_get(:@file_part_upload_config) || {}
    end

    def get_mode
      file_part_upload_config[:mode] || :local
    end

    def get_path
      file_part_upload_config[:path] || ":class/:id/attach/:name"
    end

    def get_url
      url_config = file_part_upload_config[:url] || get_path
      File.join("/", url_config)
    end

    def get_qiniu_domain
      file_part_upload_config[:qiniu_domain]
    end

    def get_qiniu_base_path
      file_part_upload_config[:qiniu_base_path]
    end

    def get_qiniu_bucket
      file_part_upload_config[:qiniu_bucket]
    end

  end

end

require 'enumerize'
# 引用 rails engine
require 'file_part_upload/engine'
require 'file_part_upload/mini_magick'
require 'file_part_upload/office_methods'
require 'file_part_upload/local_validate'
require 'file_part_upload/local_callback'
require 'file_part_upload/local_methods'
require 'file_part_upload/local_path_util'

require 'file_part_upload/upload_file'
require 'file_part_upload/util'
require 'file_part_upload/error'
require 'file_part_upload/file_entity'
require 'file_part_upload/config'
require 'file_part_upload/controller_helper'
require 'file_part_upload/office_helper'

require 'file_part_upload/module_loader'
require 'file_part_upload/qiniu_validate'
require 'file_part_upload/qiniu_create_methods'
require 'file_part_upload/qiniu_methods'
