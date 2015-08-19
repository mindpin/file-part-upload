module FilePartUpload
  module LocalValidate
    def self.included(base)
      base.validates :original,    :presence => true
      base.validates :file_size,   :presence => true
      base.validates :mime,        :presence => true
      base.validates :kind,        :presence => true
      base.validates :saved_size,  :presence => true

      base.before_validation :set_default_saved_size
      base.before_validation :set_mime_and_kind_by_file_name
    end

    def set_default_saved_size
      self.saved_size = 0 if self.saved_size.blank?
    end

    def set_mime_and_kind_by_file_name
      if self.original.present?
        # set mime
        new_mime  = Util.mime_type(self.original)
        self.mime = new_mime if new_mime != self.mime

        # set kind
        new_kind  = new_mime.split("/").first
        self.kind = new_kind if new_kind != self.kind
      end
    end

  end
end
