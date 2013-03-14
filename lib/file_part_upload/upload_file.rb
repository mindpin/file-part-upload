module FilePartUpload
  class UploadFile
    def initialize(file)
      @file = file
    end

    def path
      @file.path
    end

    def name
      if @file.respond_to?(:original_filename)
        @file.original_filename
      else
        File.basename(@file.path)
      end
    end

    def size
      @file.size
    end

    def copy_to(new_path)
      FileUtils.mkdir_p(File.dirname(new_path))
      FileUtils.cp(self.path, new_path)
    end
  end
end