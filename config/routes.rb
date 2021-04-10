Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :episodes, only: [:show] do
    member do
      get :v1, action: :show_v1
      get :v2, action: :show_v2
      get :dev_compare
    end
    resources :chapters, only: [] do
      resource :picture, only: [:show]
    end
  end

  namespace :admin do
    root to: 'main#show'
    resources :podcasts do
      resources :episodes do
        resources :paragraphs
        resource :timed_script
        resource :timed_script2
        resources :timed_paragraphs
        resource :description_partitioning
        resource :downloadable_transcript
        resource :timed_script_combining
      end
      resources :transcripts
    end
    get 'experiments/:action', controller: 'experiments'
  end

  post :translate, to: 'translate#translate'
  root to: 'main#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
