Rails.application.routes.draw do
  root 'welcome#show'

  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create]
end
