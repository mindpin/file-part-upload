module FilePartUpload
  class UploadFile
    def initialize(file)
      @file = file
    end

    def path
      @file.path
    end

    def name
      File.basename(@file.path)
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