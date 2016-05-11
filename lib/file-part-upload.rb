module FilePartUpload
  DEFAULT_VIDEO_TRANSCODE_PARAMS = [
    {
      name: "原画",# 源画质
      video_width: nil,
      video_height: nil,
      video_bit_rate: nil,
      audio_bit_rate: 32000
    },
    {
      name: "超请",
      video_width: 1280,
      video_height: 720,
      video_bit_rate: 921600,
      audio_bit_rate: 64000
    },
    {
      name: "高清",
      video_width: 960,
      video_height: 540,
      video_bit_rate: 518400,
      audio_bit_rate: 32000
    },
    {
      name: "标清",
      video_width:    640,
      video_height:   360,
      video_bit_rate: 230400,
      audio_bit_rate: 32000
    }
  ]

  class << self
    def config(&block)
      # 读取配置
      FilePartUpload::Config.config(&block)

      require 'qiniu'
      require 'qiniu/http'

      Qiniu.establish_connection! :access_key => FilePartUpload.get_qiniu_app_access_key,
                                  :secret_key => FilePartUpload.get_qiniu_app_secret_key
    end

    def file_part_upload_config
      self.instance_variable_get(:@file_part_upload_config) || {}
    end

    def get_mode
      file_part_upload_config[:mode] || :qiniu
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
      FilePartUpload::Engine.routes.url_helpers.root_path
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

    def get_qiniu_video_transcode_params
      file_part_upload_config[:qiniu_video_transcode_params] || DEFAULT_VIDEO_TRANSCODE_PARAMS
    end

    def get_qiniu_pfop_pipeline
      file_part_upload_config[:qiniu_pfop_pipeline]
    end

    def get_qiniu_callback_url
      File.join(get_qiniu_callback_host, get_mount_prefix, "/file_entities")
    end

    def get_qiniu_pfop_notify_url
      File.join(get_qiniu_callback_host, get_mount_prefix, "/file_entities/pfop")
    end

    # 获取页面上需要给上传按钮设置的 data
    def get_dom_data
      {
        :mode              =>  get_mode,
        :qiniu_domain      =>  get_qiniu_domain,
        :qiniu_base_path   =>  get_qiniu_base_path,
        :qiniu_uptoken_url =>  File.join(get_mount_prefix, "/file_entities/uptoken"),
        :qiniu_callback_url => File.join(get_mount_prefix, "/file_entities")
      }
    end

  end

end

require 'enumerize'
# 引用 rails engine
require 'file_part_upload/engine'

require 'file_part_upload/util'
require 'file_part_upload/error'
require 'file_part_upload/config'

require 'file_part_upload/rails_routes'
