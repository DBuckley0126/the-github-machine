Rails.application.routes.draw do
  root 'homepage#index' # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/show', to: 'homepage#show'
end
