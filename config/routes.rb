Rails.application.routes.draw do
  resources :episodes, only: [:show] do
    member do
      get :v2, action: :show_v2
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
      member do
        get :timed_script
      end
    end
    resources :transcripts
  end

  post :translate, to: 'translate#translate'
  post :feedback, to: 'feedback#feedback'
  root to: 'main#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
