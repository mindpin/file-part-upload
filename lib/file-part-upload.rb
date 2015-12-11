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

    def set_mount_prefix(mount_prefix)
      config = FilePartUpload.file_part_upload_config
      config[:mount_prefix] = mount_prefix
      FilePartUpload.instance_variable_set(:@file_part_upload_config, config)
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

    def get_mount_prefix
      file_part_upload_config[:mount_prefix]
    end

    def get_qiniu_callback_host
      file_part_upload_config[:qiniu_callback_host]
    end

    def get_qiniu_app_access_key
      file_part_upload_config[:qiniu_app_access_key]
    end

    def get_qiniu_app_secret_key
      file_part_upload_config[:qiniu_app_secret_key]
    end

    def get_image_versions
      file_part_upload_config[:image_versions]
    end

    def get_qiniu_image_versions
      file_part_upload_config[:qiniu_image_versions]
    end

    def get_qiniu_audio_and_video_transcode
      file_part_upload_config[:qiniu_audio_and_video_transcode]
    end

    def get_qiniu_callback_url
      File.join(get_qiniu_callback_host, get_mount_prefix, "/file_entities")
    end

    # 获取页面上需要给上传按钮设置的 data
    def get_dom_data
      if :qiniu == get_mode
        {
          :mode              => get_mode,
          :qiniu_domain      => get_qiniu_domain,
          :qiniu_base_path   => get_qiniu_base_path,
          :qiniu_uptoken_url => File.join(get_mount_prefix, "/file_entities/uptoken"),
          :qiniu_callback_url => get_qiniu_callback_url
        }
      else
        {
          :mode             => get_mode,
          :local_upload_url => File.join(get_mount_prefix, "/file_entities/upload")
        }
      end

    end

  end

end

require 'enumerize'
require 'streamio-ffmpeg'
require "mini_magick"
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
require 'file_part_upload/office_helper'

require 'file_part_upload/module_loader'

require "file_part_upload/local_controller_methods"
require "file_part_upload/qiniu_controller_methods"

require 'file_part_upload/qiniu_validate'
require 'file_part_upload/qiniu_create_methods'
require 'file_part_upload/qiniu_methods'
require 'file_part_upload/transcoding_record'

require 'file_part_upload/rails_routes'
