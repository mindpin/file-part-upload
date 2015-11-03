module FilePartUpload
  module QiniuMethods

    def url(version = nil)
      base_url = File.join(FilePartUpload.get_qiniu_domain, token)

      return base_url if version == nil

      image_versions = FilePartUpload.file_part_upload_config[:qiniu_image_versions]
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

  end
end
