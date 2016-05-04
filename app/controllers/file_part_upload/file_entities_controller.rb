module FilePartUpload
  class FileEntitiesController < FilePartUpload::ApplicationController

    if :qiniu == FilePartUpload.get_mode
      include FilePartUpload::QiniuControllerMethods
    end

    def show
      @file_entity = FilePartUpload::FileEntity.find params[:id]
    end

  end
end
