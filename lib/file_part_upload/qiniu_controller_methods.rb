module FilePartUpload
  module QiniuControllerMethods

    def self.included(base)
      base.skip_before_filter :verify_authenticity_token, :only => [:upload]
    end

    def uptoken
      uri = URI.parse(request.original_url)
      callback_url = File.join("http://#{uri.host}", uri.path.gsub("/uptoken",""))

      put_policy = Qiniu::Auth::PutPolicy.new(FilePartUpload.get_qiniu_bucket)
      put_policy.callback_url = callback_url
      put_policy.callback_body = 'bucket=$(bucket)&token=$(key)&file_size=$(fsize)&image_rgb=$(imageAve.RGB)&original=$(x:original)&mime=$(mimeType)&image_width=$(imageInfo.width)&image_height=$(imageInfo.height)&avinfo_format=$(avinfo.format.format_name)&avinfo_total_bit_rate=$(avinfo.format.bit_rate)&avinfo_total_duration=$(avinfo.format.duration)&avinfo_video_codec_name=$(avinfo.video.codec_name)&avinfo_video_bit_rate=$(avinfo.video.bit_rate)&avinfo_video_duration=$(avinfo.video.duration)&avinfo_height=$(avinfo.video.height)&avinfo_width=$(avinfo.video.width)&avinfo_audio_codec_name=$(avinfo.audio.codec_name)&avinfo_audio_bit_rate=$(avinfo.audio.bit_rate)&avinfo_audio_duration=$(avinfo.audio.duration)'
      uptoken = Qiniu::Auth.generate_uptoken(put_policy)
      render json: {
        uptoken: uptoken
      }
    end

    def create
      # params 结构
      # { "bucket"=>"fushang318",
      #   "token"=>"/i/yscPYbwk.jpeg",
      #   "file_size"=>"3514",
      #   "image_rgb"=>"0xee4f60",
      #   "original"=>"icon200x200.jpeg",
      #   "mime" => "image/png",
      #   "image_width"=>"200",
      #   "image_height"=>"200",
      #   "avinfo_format" => "",
      #   "avinfo_total_bit_rate" => "",
      #   "avinfo_total_duration" => "",
      #   "avinfo_video_codec_name" => "",
      #   "avinfo_video_bit_rate"   => "",
      #   "avinfo_video_duration"   => "",
      #   "avinfo_height"           => "",
      #   "avinfo_width"            => "",
      #   "avinfo_audio_codec_name" => "",
      #   "avinfo_audio_bit_rate"   => "",
      #   "avinfo_audio_duration"   => ""
      # }
      file_entity = FilePartUpload::FileEntity.from_qiniu_callback_body(params)
      render json: {
        :file_entity_id  => file_entity.id.to_s,
        :file_entity_url => file_entity.url
      }
    end

  end
end
