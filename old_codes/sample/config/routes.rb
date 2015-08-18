Rails.application.routes.draw do
  root 'index#index'
  post "/upload" => 'index#upload'
end
