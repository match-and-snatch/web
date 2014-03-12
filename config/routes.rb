BuddyPlatform::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#show'

  resources :posts, only: [] do
    resources :comments, only: [:create, :index]
  end

  resource :session

  resources :users, only: [:index, :create, :edit, :update] do
    member do
      put :update_payment_information
      get :account_settings
      put :update_general_information
      put :change_password
      get :billing_information
      put :update_bank_account_data
      get :edit_cc_data
      put :update_cc_data
      put :update_name
      put :update_cost
      put :update_profile_picture
      put :update_cover_picture
    end

    resources :benefits, only: [:create]
    resources :posts, only: [:index, :create]
    resources :subscriptions, only: [:new, :create, :index] do
      collection do
        post :via_register
        post :via_update_cc_data
      end
    end
    scope module: :users do
      resources :uploads, only: [:create]
    end
  end

  get '/account_info' => 'users#account_info', as: :account_info
  get '/logout' => 'sessions#logout', as: :logout
  get '/login' => 'sessions#new', as: :login
  get '/finish_profile' => 'users#edit', as: :finish_profile

  if Rails.env.development?
    get 'mockups/*mockup' => 'mockups#show'
  end

  get '/:id' => 'users#show', as: :profile

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
