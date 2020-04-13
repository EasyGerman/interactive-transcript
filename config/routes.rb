Rails.application.routes.draw do
  resources :episodes, only: [:index, :show]
  root to: 'main#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
