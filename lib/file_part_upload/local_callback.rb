module FilePartUpload
  module LocalCallback

    def self.included(base)
      base.before_create :set_token_by_original
    end

    def set_token_by_original
      token = Util.get_randstr_filename(self.original)
      write_attribute(:token, token)
    end

  end
end
