Rails.application.routes.draw do
	root "welcome#index"

	resources :matches
	resources :snatches
	resources :chats
	resources :radars
	resources :favorites
end