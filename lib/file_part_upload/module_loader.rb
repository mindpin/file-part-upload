module FilePartUpload
  class ModuleLoader
    def self.load_by_mode!

      if :local == FilePartUpload.get_mode
        FilePartUpload::FileEntity.send :include, FilePartUpload::LocalValidate
        FilePartUpload::FileEntity.send :include, FilePartUpload::LocalCallback
        FilePartUpload::FileEntity.send :include, FilePartUpload::LocalMethods
      end

      if :qiniu == FilePartUpload.get_mode
        FilePartUpload::FileEntity.send :include, FilePartUpload::QiniuValidate
        FilePartUpload::FileEntity.send :include, FilePartUpload::QiniuCreateMethods
        FilePartUpload::FileEntity.send :include, FilePartUpload::QiniuMethods
      end

    end
  end
end
