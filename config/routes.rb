BuddyPlatform::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#show'

  resources :posts, only: [] do
    resources :comments, only: [:create, :index]
  end

  resource :session

  resource :account_info, only: :show do
    member do
      put :update_payment_information
      get :settings
      put :update_general_information
      put :change_password
      get :billing_information
      put :update_bank_account_data
      get :edit_payment_information
      get :edit_cc_data
      put :update_cc_data
      put :create_profile_page
      put :delete_profile_page
    end
  end

  resources :users, only: [:index, :create, :edit, :update] do
    member do
      put :update_name
      put :update_cost
      put :update_profile_picture
      put :update_cover_picture
    end

    resources :benefits, only: :create
    resources :posts, only: [:index, :create]
    resources :subscriptions, only: [:new, :create] do
      collection do
        post :via_register
        post :via_update_cc_data
      end
    end
  end

  resources :subscriptions, only: [:index, :create]

  get '/logout' => 'sessions#logout', as: :logout
  get '/login' => 'sessions#new', as: :login
  get '/create_profile' => 'owner/first_steps#show', as: :create_profile
  put '/create_profile' => 'account_infos#create_profile_page'

  scope module: :owner do
    resource :second_step, only: %i(show update)
    resource :third_step, only: %i(show update)
  end

  if Rails.env.development?
    get 'mockups/*mockup' => 'mockups#show'
  end

  get '/:id' => 'users#show', as: :profile
end
