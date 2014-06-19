module FilePartUpload
  module Instance
    def self.included(base)
      base.after_save do
        if @upload_file.present?
          @upload_file.copy_to(self.attach.path)
          self.attach.resize!
        end
      end
    end

    def attach
      if self.saved_file_name.present?
        Attach.new(
                    :instance => self, 
                    :name => self.saved_file_name, 
                    :size => self.attach_file_size
                  )
      end
    end

    def attach=(file)
      @upload_file = UploadFile.new(file)

      self.attach_file_name    = @upload_file.original_filename
      self.attach_content_type = @upload_file.content_type
      self.attach_file_size    = @upload_file.size 
      self.saved_size          = @upload_file.size
      self.merged              = true
    end

    def attach_file_name=(attach_file_name)
      write_attribute(:attach_file_name, attach_file_name)

      saved_file_name = Util.get_randstr_filename(attach_file_name)
      write_attribute(:saved_file_name, saved_file_name)      
    end

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

    def merge
      self.saved_size = self.attach_file_size
      self.merged = true
    end

    private
    def _save_first_blob(blob)
      FileUtils.mkdir_p(File.dirname(self.attach.path))
      FileUtils.cp(blob.path,self.attach.path)
      FileUtils.chmod(0644, self.attach.path)
      self.saved_size = blob.size
      self.save

      _check_status
    end

    def _save_new_blob(file_blob)
      file_blob_size = file_blob.size
      # `cat '#{file_blob.path}' >> '#{file_path}'`
      File.open(self.attach.path,"a") do |src_f|
        File.open(file_blob.path,'r') do |f|
          src_f << f.read
        end
      end

      self.saved_size += file_blob_size
      self.save
      
      _check_status
    end

    def _check_status
      return if self.saved_size != self.attach_file_size

      self.merge
      self.save
      self.attach.resize!
    end

    def _catch_exception(file_blob)
      raise FilePartUpload::AlreadyMergedError.new if self.merged?

      ssize = self.saved_size || 0
      if ssize + file_blob.size > self.attach_file_size
        raise FilePartUpload::FileSizeOverflowError.new
      end
    end

  end
end