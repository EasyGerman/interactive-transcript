Rails.application.routes.draw do
  resources :episodes, only: [:show] do
    member do
      get :a
      get :dev_compare
    end
    resources :chapters, only: [] do
      resource :picture, only: [:show]
    end
  end

  namespace :admin do
    root to: 'main#show'
    resources :episodes do
      resources :paragraphs
    end
    resources :transcripts
  end

  post :translate, to: 'translate#translate'
  root to: 'main#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
