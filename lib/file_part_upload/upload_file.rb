module FilePartUpload
  class UploadFile
    def initialize(file)
      @file = file
    end

    def path
      @file.path
    end

    def filename
      filename ||= Util.get_randstr_filename(_original_filename)
    end

    def size
      @file.size
    end

    def copy_to(new_path)
      FileUtils.mkdir_p(File.dirname(new_path))
      FileUtils.cp(self.path, new_path)
    end

    def content_type
      Util.mime_type(_original_filename)
    end

    private
    def _original_filename
      if @file.respond_to?(:original_filename)
        @file.original_filename
      else
        File.basename(@file.path)
      end
    end

  end
end