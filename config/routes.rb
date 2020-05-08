Rails.application.routes.draw do
  resources :episodes, only: [:show] do
    resources :chapters, only: [] do
      resource :picture, only: [:show]
    end
  end

  namespace :admin do
    resources :episodes, only: [:index, :create]
  end

  post :translate, to: 'translate#translate'
  root to: 'main#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
