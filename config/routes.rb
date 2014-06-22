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
      get :confirm_profile_page_removal
      put :delete_profile_page
      put :update_account_picture
      put :enable_rss
      put :disable_rss
      put :enable_downloads
      put :disable_downloads
      put :enable_itunes
      put :disable_itunes
    end

    scope module: :account_info do
      resources :messages, only: [:create]
      resources :dialogues, only: [:index, :show] do
        member do
          put :mark_as_read
        end
      end
    end
  end

  resources :comments, only: [:edit, :update, :destroy] do
    member do
      put :make_visible
      put :hide
    end
    resources :replies, only: [:create, :edit, :update] do
      member do
        put :make_visible
        put :hide
      end
    end
  end

  resources :posts, only: [:show, :edit, :update, :destroy] do
    member do
      put :make_visible
      put :hide
    end
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
  resource :sitemap, only: :show

  resources :subscribers, only: [:index, :destroy]
  resources :subscriptions, only: [:index, :create, :destroy] do
    member do
      get :cancel
      put :enable_notifications
      put :disable_notifications
      put :restore
    end
  end
  resources :audios, only: [:show, :create, :destroy] do
    collection do
      post :reorder
    end
  end
  resources :videos, only: [:create, :destroy]
  resources :photos, only: [:show, :create, :destroy]
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

    resources :messages, only: [:new, :create]

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
    resource :rss_feed, only: :show, defaults: {format: :atom}
  end

  resources :profile_types, only: [:index, :create, :destroy]

  namespace :admin do
    resources :payment_failures , only: :index
    resources :payments, only: :index
    resources :payout_details, only: :index
    resources :staffs, only: :index do
      collection do
        get :search
      end
    end
    resources :uploads, only: :index
    resources :profile_owners, only: [:index, :show] do
      member do
        get :finance_details
      end
    end
    resources :profiles, only: [:index, :show] do
      collection do
        get :public
      end

      member do
        put :make_public
        put :make_private
      end
    end

    resources :users, only: :index do
      collection do
        get :search
      end
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
  get '/mentions' => 'users#mentions', as: :mentions
  get '/activate' => 'users#activate', as: :activate

  if Rails.env.development?
    get 'mockups/*mockup' => 'mockups#show'
    get 'emails/*mockup' => 'emails#show'
  end

  get '/:id' => 'users#show', as: :profile
end
