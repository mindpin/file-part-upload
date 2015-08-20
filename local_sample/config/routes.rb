Rails.application.routes.draw do
  get '/upload_local' => 'upload#local'
  # mount FilePartUpload::Engine => '/file_part_upload', :as => 'file_part_upload'
  FilePartUpload::Routing.mount "/file_part_upload", :as => 'file_part_upload'
end
