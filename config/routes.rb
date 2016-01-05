FilePartUpload::Engine.routes.draw do
  root 'home#index'

  resources :file_entities do
    post :upload, on: :collection
    get :uptoken, on: :collection
    post :pfop,    on: :collection
  end
end
