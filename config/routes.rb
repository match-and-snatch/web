Rails.application.routes.draw do
  root 'welcome#show'

  resources :offers, only: [:new, :create, :show, :destroy] do
    member do
      patch :toggle_favorite
      patch :like
      patch :dislike
    end

    resources :messages, only: [:create]
  end
  resources :sessions, only: [:new, :create, :destroy]
  resources :users, only: [:new, :create]
end
