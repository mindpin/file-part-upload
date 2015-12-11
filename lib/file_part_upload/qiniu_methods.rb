module FilePartUpload
  module QiniuMethods
    def self.included(base)
      base.has_many :transcoding_records, :class_name => "FilePartUpload::TranscodingRecord"
      base.after_create :process_transcode
    end

    def process_transcode
      case self.mime.split("/").first
      when 'audio'
        put_audio_transcode_to_quene
      when 'video'
        put_video_transcode_to_quene
      end
      return true
    end

    def is_audio?
      self.mime.split("/").first == "audio"
    end

    def is_video?
      self.mime.split("/").first == "video"
    end

    def transcode_url(transcoding_record_name = "default")
      self.transcoding_records.where(:name => transcoding_record_name).first.try(:url)
    end

    def transcode_success?
      self.transcoding_records.select do |tr|
        tr.get_status.to_s != "success"
      end.count == 0
    end

    def transcode_info
      self.transcoding_records.map{|tr|[tr.name,tr.get_status.to_s]}.to_h
    end

    def url(version = nil)
      base_url = File.join(FilePartUpload.get_qiniu_domain, token)

      return base_url if version == nil

      image_versions = FilePartUpload.get_qiniu_image_versions
      return base_url if image_versions.blank?

      version_info = image_versions[version.to_s]
      return base_url if version_info.blank?

      width  = version_info[:args][0]
      height = version_info[:args][1]

      case version_info[:type].to_s
      when "resize_to_fill"
        return "#{base_url}?imageMogr2/thumbnail/!#{width}x#{height}r/gravity/Center/crop/#{width}x#{height}"
      when "resize_to_fit"
        return "#{base_url}?imageMogr2/thumbnail/#{width}x#{height}"
      else
        return base_url
      end
    end

    def path
      token
    end

    def put_audio_transcode_to_quene
      bit_rate = self.meta["audio"]["total_bit_rate"]
      if bit_rate.to_i >= 128000
        # 转码 128k
        return put_audio_transcode_to_quene_by_bit_rate("128k")
      end

      if bit_rate.to_i >= 64000
        # 转码 64k
        return put_audio_transcode_to_quene_by_bit_rate("64k")
      end

      put_audio_transcode_to_quene_by_bit_rate("32k")
    end

    def put_video_transcode_to_quene
      # 完全按照 http://www.youku.com/help/view/fid/8#q20
      # 的逻辑会很复杂，需要借助一些数据后才能调整
      # 先用简化的逻辑处理
      bit_rate = self.meta["video"]["total_bit_rate"]

      if bit_rate.to_i >= 3500000
        # 转码超清
        return put_video_transcode_to_quene_by_bit_rate("3.5m", "320k")
      end

      if bit_rate.to_i >= 1500000
        # 转码超清
        return put_video_transcode_to_quene_by_bit_rate("1.5m", "320k")
      end

      if bit_rate.to_i >= 1000000
        # 转码高清
        return put_video_transcode_to_quene_by_bit_rate("1m","128k")
      end

      put_video_transcode_to_quene_by_bit_rate(bit_rate.to_i-64000,"64k")
    end

    # key 去掉 ext
    def transcode_file_path
      arr = token.split(".")
      arr.pop
      arr.join(".")
    end

    def put_video_transcode_to_quene_by_bit_rate(video_bit_rate, audio_bit_rate)
      fops = "avthumb/mp4/vcodec/libx264/vb/#{video_bit_rate}/acodec/libmp3lame/ab/#{audio_bit_rate}"
      transcode_token = File.join(transcode_file_path, "#{video_bit_rate}.mp4")
      put_transcode_to_quene(fops, transcode_token)
    end

    # bit_rate -> 128K
    def put_audio_transcode_to_quene_by_bit_rate(bit_rate)
      fops = "avthumb/mp3/acodec/libmp3lame/ab/#{bit_rate}"
      transcode_token = File.join(transcode_file_path, "#{bit_rate}.mp3")
      put_transcode_to_quene(fops, transcode_token)
    end

    def put_transcode_to_quene(fops, transcode_token)
      transcoding_record = self.transcoding_records.create(
        :name  => "default",
        :token => transcode_token,
        :fops      => fops
      )
    end

  end
end
