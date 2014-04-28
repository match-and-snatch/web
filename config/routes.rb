BuddyPlatform::Application.routes.draw do
  root 'welcome#show'

  resource :account_info, only: [] do
    member do
      put :update_payment_information
      get :settings
      put :update_general_information
      put :update_slug
      put :change_password
      get :billing_information
      put :update_bank_account_data
      get :edit_payment_information
      get :edit_cc_data
      get :details
      put :update_cc_data
      put :create_profile_page
      put :delete_profile_page
      put :update_account_picture
    end
  end

  resources :comments, only: [:destroy]

  resources :posts, only: [:destroy, :show] do
    resources :comments, only: [:create, :index]
    resources :likes, only: :create
  end

  resource :pending_post, only: [:update]

  resources :status_posts, only: [:new, :create]
  resources :audio_posts, only: [:new, :create] do
    delete :cancel, on: :collection
  end
  resources :video_posts, only: [:new, :create] do
    delete :cancel, on: :collection
  end
  resources :photo_posts, only: [:new, :create]do
    delete :cancel, on: :collection
  end
  resources :document_posts, only: [:new, :create] do
    delete :cancel, on: :collection
  end

  resource :session

  resources :subscribers, only: [:index, :destroy]
  resources :subscriptions, only: [:index, :create, :destroy] do
    member do
      get :cancel
    end
  end
  resources :audios, only: [:create, :destroy]
  resources :videos, only: [:create, :destroy]
  resources :photos, only: [:create, :destroy]
  resources :documents, only: [:create, :destroy]

  resources :users, only: [:index, :create, :edit, :update] do
    member do
      put :update_name
      put :update_cost
      put :update_profile_picture
      put :update_cover_picture
      put :update_contacts_info
      put :update_cover_picture_position
    end

    resources :photos, only: [] do
      collection do
        get :profile_picture
        get :cover_picture
      end
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

  resources :profile_types, only: [:index, :create, :destroy]

  namespace :admin do
    resources :payments, only: :index
    resources :staffs, only: :index
    resources :profiles, only: [:index, :new] do
      collection do
        get :profile_owners
      end

      member do
        put :make_public
        put :make_private
      end
    end

    resources :users, only: :index do
      member do
        put :make_admin
        put :drop_admin
        post :login_as
      end
    end
    resources :profile_types, only: [:index, :create, :destroy]
  end

  resource :password, only: [:edit, :update] do
    member do
      post 'restore'
    end
  end

  resource :feed, only: :show

  get '/application_settings' => 'admin/dashboard#show', as: :application_settings
  get '/logout' => 'sessions#logout', as: :logout
  get '/login' => 'sessions#new', as: :login
  get '/create_profile' => 'owner/first_steps#show', as: :create_profile
  get '/account' => 'account_infos#show', as: :account_info
  put '/create_profile' => 'account_infos#create_profile_page'

  scope module: :owner do
    resource :second_step, only: %i(show update)
    resource :third_step, only: %i(show update)
  end

  get '/about' => 'pages#about', as: :about
  get '/pricing' => 'pages#pricing', as: :pricing
  get '/contact_us' => 'pages#contact_us', as: :contact_us
  get '/terms_of_use' => 'pages#terms_of_use', as: :terms_of_use
  get '/privacy_policy' => 'pages#privacy_policy', as: :privacy_policy
  get '/faq' => 'pages#faq', as: :faq
  get '/sampleprofile' => 'pages#sampleprofile', as: :sampleprofile

  if Rails.env.development?
    get 'mockups/*mockup' => 'mockups#show'
    get 'emails/*mockup' => 'emails#show'
  end

  get '/:id' => 'users#show', as: :profile
end
