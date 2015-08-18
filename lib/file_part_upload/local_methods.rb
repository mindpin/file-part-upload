module FilePartUpload
  module LocalMethods

    def uploaded?
      self.merged?
    end

    def uploading?
      !self.uploaded?
    end

    def save_blob(file_blob)
      _catch_exception(file_blob)
      if self.saved_size == 0 || self.saved_size.blank?
        _save_first_blob(file_blob)
      else
        _save_new_blob(file_blob)
      end
    end

    def path(version = nil)
      res = LocalPathUtil.convert_path(self, FilePartUpload.get_path, version)
      return res if res[0] == "/"

      File.join(FilePartUpload.root, res)
    end

    def url(version = nil)
      res = LocalPathUtil.convert_path(self, FilePartUpload.get_url, version)
      return res if res[0] == "/"

      File.join(FilePartUpload.base_path, res)
    end

    def image_resize!
      return if !self.mime.match("image")
      FilePartUpload::MiniMagick.resize!(self)
    end

    private
    def merge
      self.saved_size = self.file_size
      self.merged = true
    end

    def _save_first_blob(blob)
      FileUtils.mkdir_p(File.dirname(self.path))
      FileUtils.cp(blob.path,self.path)
      FileUtils.chmod(0644, self.path)
      self.saved_size = blob.size
      self.save

      _check_status
    end

    def _save_new_blob(file_blob)
      file_blob_size = file_blob.size
      # `cat '#{file_blob.path}' >> '#{file_path}'`
      File.open(self.path,"a") do |src_f|
        File.open(file_blob.path,'r') do |f|
          src_f << f.read
        end
      end

      self.saved_size += file_blob_size
      self.save

      _check_status
    end

    def _check_status
      return if self.saved_size != self.file_size

      self.send(:merge)
      self.save
      self.image_resize!
    end

    def _catch_exception(file_blob)
      raise FilePartUpload::AlreadyMergedError.new if self.merged?

      ssize = self.saved_size || 0
      if ssize + file_blob.size > self.file_size
        raise FilePartUpload::FileSizeOverflowError.new
      end
    end

  end
end
