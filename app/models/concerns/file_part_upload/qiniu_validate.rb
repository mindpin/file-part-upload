module FilePartUpload
  module QiniuValidate
    def self.included(base)
      base.before_validation :set_kind_by_mime
    end

    def set_kind_by_mime

      if self.mime.present?
        new_kind = FilePartUpload::Util.get_file_kind_by_mime_type(self.mime)
        self.kind = new_kind if new_kind != self.kind
        # 七牛的 mime 有时候有问题，比如 mpg 格式的视频，七牛会识别成 audio/mpeg
        # 这个情况通过 meta 字段信息 fix
        self.kind = "video" if !self.meta["video"].blank? && self.kind != "video"
        self.kind = "audio" if !self.meta["audio"].blank? && self.kind != "audio"
      end
    end

  end
end
