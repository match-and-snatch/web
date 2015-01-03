Rails.application.routes.draw do
  root 'welcome#show'

  resources :offers, only: [:new, :create, :show]
  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create]
end
