module FilePartUpload
  module Instance
    extend ActiveSupport::Concern

    included do |base|
      base.before_save do
        if @upload_file.present?
          self.attach_file_name = @upload_file.filename
          self.attach_content_type = @upload_file.content_type
          self.attach_file_size = @upload_file.size 
          self.saved_size = @upload_file.size
          self.merged = true
        end
      end

      base.after_save do
        if @upload_file.present?
          @upload_file.copy_to(self.attach.path)
        end
      end
    end

    def attach
      if self.attach_file_name.present?
        Attach.new(
                    :instance => self, 
                    :name => self.attach_file_name, 
                    :size => self.attach_file_size
                  )
      end
    end

    def attach=(file)
      @upload_file = UploadFile.new(file)
    end

    def uploaded?
      self.merged?
    end

    def uploading?
      !self.uploaded?
    end

    def save_blob(file_blob)
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
      self.attach_content_type = Util.mime_type(self.attach_file_name)
      self.save
    end


  end
end