Rails.application.routes.draw do
	root "welcome#index"

	resources :matches
	resources :snatches
	resources :chats
end