module FilePartUpload
  module QiniuValidate
    def self.included(base)
      base.before_validation :set_kind_by_mime
    end

    def set_kind_by_mime
      if self.mime.present?
        new_kind = FilePartUpload::Util.get_file_kind_by_mime_type(self.mime)
        self.kind = new_kind if new_kind != self.kind
      end
    end

  end
end
