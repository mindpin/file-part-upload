module FilePartUpload
  module QiniuMethods

    def url
      File.join(FilePartUpload.get_qiniu_domain, token)
    end

    def path
      token
    end

  end
end
