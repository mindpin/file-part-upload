module FilePartUpload
  module LocalCallback

    def self.included(base)
      base.before_create :set_token_by_original
      base.before_save :set_meta_by_saved_file
    end

    def set_token_by_original
      token = Util.get_randstr_filename(self.original)
      write_attribute(:token, token)
    end

    def set_meta_by_saved_file
      return true if !self.uploaded?
      return true if !File.exists?(self.path)

      if self.kind.image?
        _set_image_meta_by_saved_file
      end

      if self.kind.video?
        _set_video_meta_by_saved_file
      end

    end

    def _set_image_meta_by_saved_file
      img = ::MiniMagick::Image.new(self.path)
      self.meta["image"] ||= {}
      self.meta["image"]["width"]  = img[:width]
      self.meta["image"]["height"] = img[:height]
    end

    def _set_video_meta_by_saved_file
      vid = FFMPEG::Movie.new(self.path)
      self.meta["video"] ||= {}
      self.meta["video"]["total_duration"] = vid.duration
    end

  end
end
