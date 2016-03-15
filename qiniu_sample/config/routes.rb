Rails.application.routes.draw do
  get '/upload_qiniu' => 'upload#qiniu'
  mount FilePartUpload::Engine => '/file_part_upload', :as => 'file_part_upload'
  mount PlayAuth::Engine => '/auth', :as => :auth
end
