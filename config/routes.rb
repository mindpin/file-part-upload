FilePartUpload::Engine.routes.draw do
  root 'home#index'
  get "/file_entities/new" => "file_entities#new"


  post "/file_entities/upload"  => "file_entities#upload"
  get  "/file_entities/uptoken" => "file_entities#uptoken"
  post "/file_entities"         => "file_entities#create"
end
