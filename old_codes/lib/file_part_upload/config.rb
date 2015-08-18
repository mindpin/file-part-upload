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

    #######
    def self.image_version(version_name, &block)
      config = FilePartUpload.file_part_upload_config
      config[:image_versions] ||= []
      process_type, process_args = self.instance_eval &block
      config[:image_versions] << {
        :name => version_name.to_s,
        :type => process_type.to_s,
        :args => process_args
      }
      FilePartUpload.instance_variable_set(:@file_part_upload_config, config) 
    end

    def self.process(process_attr)
      raise "不能同时使用 resize_to_fill resize_to_fit" if !!process_attr[:resize_to_fit] && !!process_attr[:resize_to_fill]
      return :resize_to_fill, process_attr[:resize_to_fill] if !!process_attr[:resize_to_fill]
      return :resize_to_fit, process_attr[:resize_to_fit] if !!process_attr[:resize_to_fit]
    end
    #######

    def self.add_methods(_module)
      FilePartUpload::FileEntity.send(:include, _module)
    end
  end
end