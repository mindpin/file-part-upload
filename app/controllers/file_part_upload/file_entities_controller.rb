module FilePartUpload
  class FileEntitiesController < FilePartUpload::ApplicationController

    if :local == FilePartUpload.get_mode
      include FilePartUpload::LocalControllerMethods
    end

    if :qiniu == FilePartUpload.get_mode
      include FilePartUpload::QiniuControllerMethods
    end

  end
end
