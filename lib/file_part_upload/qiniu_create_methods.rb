module FilePartUpload
  module QiniuCreateMethods
    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods

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
      def from_qiniu_callback_body(callback_body)
        qiniu_base_path = FilePartUpload.get_qiniu_base_path

        callback_body[:file_size] = callback_body[:file_size].to_i
        meta = __get_meta_from_callback_body(callback_body[:mime], callback_body)

        FilePartUpload::FileEntity.create!(
          original: callback_body[:original],
          token:    callback_body[:token],
          mime:     callback_body[:mime],
          meta: meta
        )
      end


      def __get_meta_from_callback_body(mime, callback_body)
        file_size  = callback_body[:file_size]

        is_image = !callback_body[:image_rgb].blank?
        is_video = !callback_body[:avinfo_video_codec_name].blank?
        is_audio = !callback_body[:avinfo_audio_codec_name].blank? && callback_body[:avinfo_video_codec_name].blank?

        if is_image
          rgb   = callback_body[:image_rgb]
          rgba  = "rgba(#{rgb[2..3].hex},#{rgb[4..5].hex},#{rgb[6..7].hex},0)"
          hex   = "##{rgb[2..7]}"

          width      = callback_body[:image_width]
          height     = callback_body[:image_height]

          return {
            "file_size" => file_size,
            "image" => {
              "rgba"   => rgba,
              "hex"    => hex,
              "height" => height,
              "width"  => width
            }
          }
        end

        if is_video
          return {
            "file_size" => file_size,
            "video" => {
              "format"                => callback_body[:avinfo_format],
              "total_bit_rate"        => callback_body[:avinfo_total_bit_rate],
              "total_duration"        => callback_body[:avinfo_total_duration],
              "video_codec_name"      => callback_body[:avinfo_video_codec_name],
              "video_bit_rate"        => callback_body[:avinfo_video_bit_rate],
              "video_duration"        => callback_body[:avinfo_video_duration],
              "height"                => callback_body[:avinfo_height],
              "width"                 => callback_body[:avinfo_width],
              "audio_codec_name"      => callback_body[:avinfo_audio_codec_name],
              "avinfo_audio_bit_rate" => callback_body[:avinfo_audio_bit_rate],
              "avinfo_audio_duration" => callback_body[:avinfo_audio_duration]
            }
          }
        end

        if is_audio
          return {
            "file_size" => file_size,
            "audio" => {
              "total_bit_rate"   => callback_body[:avinfo_total_bit_rate],
              "total_duration"   => callback_body[:avinfo_total_duration],
              "audio_codec_name" => callback_body[:avinfo_audio_codec_name],
              "audio_bit_rate"   => callback_body[:avinfo_audio_bit_rate],
              "audio_duration"   => callback_body[:avinfo_audio_duration]
            }
          }
        end

        return {"file_size" => file_size}
      end


    end
  end
end
