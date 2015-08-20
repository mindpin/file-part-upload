Rails.application.routes.draw do
  get '/upload_qiniu' => 'upload#qiniu'
  # mount FilePartUpload::Engine => '/file_part_upload', :as => 'file_part_upload'
  FilePartUpload::Routing.mount "/file_part_upload", :as => 'file_part_upload'
end
