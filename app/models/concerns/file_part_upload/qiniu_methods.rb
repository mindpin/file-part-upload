module FilePartUpload
  module QiniuMethods
    def self.included(base)
      base.has_many :transcoding_records, :class_name => "FilePartUpload::TranscodingRecord"
      base.after_create :process_transcode
    end

    def process_transcode
      # TODO 转码开启关闭的配置方式修改，因为不局限于音频和视频了
      return true if FilePartUpload.get_qiniu_audio_and_video_transcode != "enable"

      case self.kind.to_s
      when 'audio'
        put_audio_transcode_to_quene
      when 'video'
        put_video_transcode_to_quene
      when 'office'
        put_office_transcode_to_quene
      when 'pdf'
        put_pdf_transcode_to_quene
      end
      return true
    end

    def transcode_url(transcoding_record_name = "default")
      self.transcoding_records.where(:name => transcoding_record_name).first.try(:url)
    end

    def transcode_urls(transcoding_record_name)
      self.transcoding_records.where(:name => transcoding_record_name).first.try(:urls)
    end

    def transcode_success?
      self.transcoding_records.select do |tr|
        tr.status.to_s != "success"
      end.count == 0
    end

    def transcode_info
      self.transcoding_records.map{|tr|[tr.name,tr.status.to_s]}.to_h
    end

    def download_url
      "#{url}?attname=#{self.original}"
    end

    def seconds
      return 0 if !self.kind.audio? && !self.kind.video?
      meta.try(:[], self.kind.to_s).try(:[], "total_duration").to_i
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
      # 参考了 http://www.youku.com/help/view/fid/8#q20
      # 参考了 http://www.lecloud.com/
      # TODO 转码规则修改成配置化的

      # 从七牛获取的 video_bit_rate 有时候是空，所以用 total_bit_rate 稳妥一些
      if defined? ::ActiveRecord::Base
        json = meta_json
      else
        json = meta
      end
      video_bit_rate = json["video"]["total_bit_rate"].to_i
      video_width    = json["video"]["width"].to_i
      video_height   = json["video"]["height"].to_i

      video_codec_name = json["video"]["video_codec_name"]

      bit_rate_mulriples = [
        {
          video_codec_name: "mpeg4",
          value: 2
        },
        {
          video_codec_name: /mpeg1|mpeg2/,
          value: 5
        }
      ]

      transcode_params_arr = [
        {
          name: "标清",
          video_width:    640,
          video_height:   360,
          video_bit_rate: 230400,
          audio_bit_rate: 32000
        },
        {
          name: "高清",
          video_width: 960,
          video_height: 540,
          video_bit_rate: 518400,
          audio_bit_rate: 32000
        },
        {
          name: "超请",
          video_width: 1280,
          video_height: 720,
          video_bit_rate: 921600,
          audio_bit_rate: 64000
        }
      ]

      mulriple_hash = bit_rate_mulriples.select do |hash|
        !video_codec_name.match(hash[:video_codec_name]).blank?
      end[0]

      if mulriple_hash.blank?
        mulriple = 1
      else
        mulriple = mulriple_hash[:value]
      end

      transcode_params_arr.each do |params|
        if video_width >= params[:video_width] && video_height >= params[:video_height] && video_bit_rate >= params[:video_bit_rate]*mulriple
          put_video_transcode_to_quene_by_bit_rate(params)
        end
      end

      min_params = transcode_params_arr[0]
      if video_width < min_params[:video_width] || video_height < min_params[:video_height] || video_bit_rate < min_params[:video_bit_rate]*mulriple
        put_video_transcode_to_quene_by_bit_rate(
          name: "低清",
          video_width: video_width,
          video_height: video_height,
          video_bit_rate: video_bit_rate,
          audio_bit_rate: 32000
        )
      end

    end

    # key 去掉 ext
    def transcode_file_path
      arr = token.split(".")
      arr.pop
      arr.join(".")
    end

    def put_video_transcode_to_quene_by_bit_rate(options)
      name           = options[:name]
      video_width    = options[:video_width]
      video_height   = options[:video_height]
      video_bit_rate = options[:video_bit_rate]
      audio_bit_rate = options[:audio_bit_rate]
      resolution     = "#{video_width}x#{video_height}"

      fops = "avthumb/mp4/vcodec/libx264/vb/#{video_bit_rate}/r/24/s/#{resolution}/autoscale/1/acodec/libfdk_aac/audioProfile/aac_he/ab/#{audio_bit_rate}/ar/44100"
      transcode_key = File.join(transcode_file_path, "#{resolution}.mp4")
      fops = FilePartUpload::Util.splice_qiniu_saveas_fops_str(fops, transcode_key)
      self.transcoding_records.create(
        :name  => name,
        :token => transcode_key,
        :fops      => fops
      )
    end

    # bit_rate -> 128K
    def put_audio_transcode_to_quene_by_bit_rate(bit_rate)
      fops = "avthumb/mp3/acodec/libmp3lame/ab/#{bit_rate}"
      transcode_key = File.join(transcode_file_path, "#{bit_rate}.mp3")
      fops = FilePartUpload::Util.splice_qiniu_saveas_fops_str(fops, transcode_key)
      self.transcoding_records.create(
        :name  => "default",
        :token => transcode_key,
        :fops      => fops
      )
    end

    def put_office_transcode_to_quene
      fops = "yifangyun_preview/v2/action=get_preview/format=pdf"
      transcode_key = File.join(transcode_file_path, "transcode.pdf")
      fops = FilePartUpload::Util.splice_qiniu_saveas_fops_str(fops, transcode_key)
      self.transcoding_records.create(
        :name  => "pdf",
        :token => transcode_key,
        :fops      => fops
      )
    end

    def put_pdf_transcode_to_quene
      update_page_count_by_pdf_url(self.url)
      put_pdf_transcode_to_quene_by_page_count
    end

    def update_page_count_by_pdf_url(pdf_url)
      json_str = RestClient.get("#{pdf_url}?yifangyun_preview/v2/action=get_page_count").body
      self.meta["page_count"] = JSON.parse(json_str)["page_count"].to_i
      self.save
    end

    def put_pdf_transcode_to_quene_by_page_count
      transcode_key_list = []
      fops_list          = []
      1.upto(self.meta["page_count"]) do |num|
        fops = "yifangyun_preview/v2/action=get_preview/format=jpg/page_number=#{num}"
        transcode_key = File.join(self.transcode_file_path, "#{num}.jpg")
        fops = FilePartUpload::Util.splice_qiniu_saveas_fops_str(fops, transcode_key)

        transcode_key_list.push transcode_key
        fops_list.push fops
      end

      self.transcoding_records.create(
        :name  => "jpg",
        :token => transcode_key_list,
        :fops      => fops_list.join(";")
      )
    end

  end
end
