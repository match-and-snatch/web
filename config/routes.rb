BuddyPlatform::Application.routes.draw do
  root 'welcome#show'
  get '/sample' => 'users#sample'
  get '/feed/itunes' => 'rss_feeds#index', defaults: {format: :atom, itunes: true}, as: :itunes_feed
  get '/crossdomain' => 'pages#crossdomain', default: {format: :xml}

  namespace :api, defaults: {format: :json} do
    resources :sessions, only: [:create]
    resources :users, only: [:create, :show] do
      collection do
        get :search
      end

      member do
        post :update_profile_name
        post :update_profile_picture
        post :update_cover_picture
        put :update_cost
      end

      resources :posts, only: [:index]
      resources :benefits, only: :create

      resources :subscriptions, only: [:new, :create] do
        collection do
          post :via_register
          post :via_update_cc_data
        end
      end
    end

    resources :posts, only: [:show, :update, :destroy] do
      member do
        delete :destroy_upload
      end
      collection do
        get :feed
      end
      resources :comments, only: [:create, :index]
      resources :likes, only: [:index, :create], defaults: { type: 'post' }
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

    resources :videos,    only: [:create, :destroy]
    resources :photos,    only: [:create, :destroy]
    resources :documents, only: [:create, :destroy]
    resources :audios,    only: [:create, :destroy] do
      collection do
        post :reorder
      end
    end

    resources :comments, only: [:update, :destroy] do
      member do
        put :make_visible
        put :hide
      end
      resources :replies, only: [:create, :update] do
        member do
          put :make_visible
          put :hide
        end
      end
      resources :likes, only: [:index, :create], defaults: { type: 'comment' }
    end

    resource :profile_info, only: [] do
      member do
        post :create_profile
      end
    end

    resource :account_info, only: [] do
      member do
        get :settings
        put :update_account_picture
        put :update_general_information
        put :update_cc_data
        put :update_bank_account_data
        put :enable_rss
        put :disable_rss
        put :enable_downloads
        put :disable_downloads
        put :enable_itunes
        put :disable_itunes
      end
    end

    match '*path' => 'cors#preflight', via: :options
  end

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
      put :enable_notifications_debug
      put :disable_notifications_debug
      put :enable_downloads
      put :disable_downloads
      put :enable_itunes
      put :disable_itunes
      get :confirm_vacation_mode_activation
      get :confirm_vacation_mode_deactivation
      put :enable_contributions
      put :disable_contributions
      post :enable_vacation_mode
      put :disable_vacation_mode
    end

    scope module: :account_info do
      resources :messages, only: [:create]
      resources :dialogues, only: [:index, :show, :destroy] do
        member do
          put :mark_as_read
          get :confirm_removal
        end
      end
      resources :logs, only: [:index]
    end
  end

  resources :comments, only: [:show, :edit, :update, :destroy] do
    member do
      put :make_visible
      put :hide
      put :like
    end
    resources :replies, only: [:create, :edit, :update] do
      member do
        put :make_visible
        put :hide
      end
    end
    resources :likes, only: [:index, :create], defaults: {type: 'comment'}
  end

  resources :contributions, only: [:index, :create, :new, :destroy] do
    member do
      get :cancel
    end
  end

  resources :contributors, only: [:index]

  resources :posts, only: [:show, :edit, :update, :destroy] do
    member do
      put :make_visible
      put :hide
      delete :destroy_upload
    end
    resources :comments, only: [:create, :index]
    resources :likes, only: [:index, :create], defaults: {type: 'post'}
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
  resources :videos, only: [:create, :destroy] do
    member do
      get :playlist
    end
  end
  resources :photos, only: [:show, :create, :destroy]
  resources :documents, only: [:create, :destroy]
  resources :pending_video_previews, only: [:create, :destroy]

  resources :users, only: [:index, :create, :edit, :update] do
    collection do
      get :search
    end

    member do
      put :update_name
      put :update_cost
      put :update_profile_picture
      delete :delete_profile_picture
      put :update_cover_picture
      delete :delete_cover_picture
      put :update_contacts_info
      put :update_cover_picture_position

      get :edit_welcome_media
      put :update_welcome_media
      delete :remove_welcome_media
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
    resources :top_profiles, except: [:show, :new] do
      collection do
        get :search
        post :update_list
      end
    end
    resources :credit_card_declines, only: [:index, :create, :destroy] do
      collection do
        get :search
      end
    end
    resources :contributions, only: :index
    resources :duplicates, only: :index
    resources :payment_failures , only: :index
    resources :payments, only: :index
    resources :payout_details, only: :index
    resources :staffs, only: :index do
      collection do
        get :search
      end
    end
    resource :directory do
      scope module: :directories do
        resources :users, only: [] do
          put :toggle, on: :member
        end
      end
    end
    resources :uploads, only: :index
    resources :recent_profiles, only: :index
    resources :profile_owners, only: [:index, :show, :update] do
      resources :transfers, only: [:index, :create]
      resources :vacations, only: [:index]
      resources :current_month_details, only: [:index]
      resources :payments, only: [] do
        collection do
          get :pending
        end
      end
      member do
        get :total_subscribed
        get :total_new_subscribed
        get :total_unsubscribed
        get :this_month_subscribers_unsubscribers
        get :failed_billing_subscriptions
        get :pending_payments
        post :change_fake_subscriptions_number
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
    resources :charts, only: [:index, :show]
    resources :payout_breakdowns, only: [:index]
    resources :cost_change_requests, only: :index do
      member do
        get :confirm_reject
        post :reject
        get :confirm_approve
        post :approve
      end
    end
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
    resource :first_step, only: :show
    resource :second_step, only: %i(show update)
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

  get '/the-painful-truth-from-neal-boortz', to: redirect('/boortzcast')
  get '/:id' => 'users#show', as: :profile
end
