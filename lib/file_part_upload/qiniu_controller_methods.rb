module FilePartUpload
  module QiniuControllerMethods

    def self.included(base)
      base.skip_before_filter :verify_authenticity_token, :only => [:upload]
    end

    def uptoken
      put_policy = Qiniu::Auth::PutPolicy.new(FilePartUpload.get_qiniu_bucket)
      put_policy.return_body = '{
        "bucket"                 : $(bucket),
        "token"                  : $(key),
        "file_size"              : $(fsize),
        "image_rgb"              : $(imageAve.RGB),
        "original"               : $(x:original),
        "mime"                   : $(mimeType),
        "image_width"            : $(imageInfo.width),
        "image_height"           : $(imageInfo.height),
        "avinfo_format"          : $(avinfo.format.format_name),
        "avinfo_total_bit_rate"  : $(avinfo.format.bit_rate),
        "avinfo_total_duration"  : $(avinfo.format.duration),
        "avinfo_video_codec_name": $(avinfo.video.codec_name),
        "avinfo_video_bit_rate"  : $(avinfo.video.bit_rate),
        "avinfo_video_duration"  : $(avinfo.video.duration),
        "avinfo_height"          : $(avinfo.video.height),
        "avinfo_width"           : $(avinfo.video.width),
        "avinfo_audio_codec_name": $(avinfo.audio.codec_name),
        "avinfo_audio_bit_rate"  : $(avinfo.audio.bit_rate),
        "avinfo_audio_duration"  : $(avinfo.audio.duration)
      }'
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

    def pfop
      # {"id"=>"z0.568b96b67823de14f7626367", "pipeline"=>"0.default", "code"=>0, "desc"=>"The fop was completed successfully", "reqid"=>"7DkAAFGcSwv_fyYU", "inputBucket"=>"fushang318", "inputKey"=>"fpu/GyrkDZW2.mp3", "items"=>[{"cmd"=>"avthumb/mp3/acodec/libmp3lame/ab/128k|saveas/ZnVzaGFuZzMxODpmcHUvR3lya0RaVzIvMTI4ay5tcDM=", "code"=>0, "desc"=>"The fop was completed successfully", "hash"=>"FlaHJmdAh39EEA5d5-cCCt5F8B9a", "key"=>"fpu/GyrkDZW2/128k.mp3", "returnOld"=>0}], "controller"=>"file_part_upload/file_entities", "action"=>"pfop", "file_entity"=>{}}
      transcoding_record = FilePartUpload::TranscodingRecord.where(:quniu_persistance_id => params[:id]).first
      if !transcoding_record.blank?
        transcoding_record.update_status_by_code(params[:code])
      end
      render :text => 200, :status => 200
    end

  end
end
