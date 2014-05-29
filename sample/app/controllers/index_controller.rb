class IndexController < ApplicationController
  def index
    @file_entities = FilePartUpload::FileEntity.all
  end

  def upload
    full_upload(params[:file])
    redirect_to "/"
  end
end
