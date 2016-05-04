module FilePartUpload
  class ModuleLoader
    def self.load_by_mode!
      if :qiniu == FilePartUpload.get_mode
        FilePartUpload::FileEntity.send :include, FilePartUpload::QiniuValidate
        FilePartUpload::FileEntity.send :include, FilePartUpload::QiniuCreateMethods
        FilePartUpload::FileEntity.send :include, FilePartUpload::QiniuMethods

        require 'qiniu'
        require 'qiniu/http'

        Qiniu.establish_connection! :access_key => FilePartUpload.get_qiniu_app_access_key,
                                    :secret_key => FilePartUpload.get_qiniu_app_secret_key


      end

    end
  end
end
