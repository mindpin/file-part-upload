module FilePartUpload
  class Config
    def self.config(&block)
      self.instance_eval &block
    end

    def self.path(str)
      config = FilePartUpload.file_part_upload_config
      config[:path] = str
      FilePartUpload.instance_variable_set(:@file_part_upload_config, config) 
    end

    def self.url(str)
      config = FilePartUpload.file_part_upload_config
      config[:url] = str
      FilePartUpload.instance_variable_set(:@file_part_upload_config, config) 
    end
  end
end