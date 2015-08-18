Rails.application.routes.draw do
  mount FilePartUpload::Engine => '/', :as => 'file_part_upload'
  mount PlayAuth::Engine => '/auth', :as => :auth
end
