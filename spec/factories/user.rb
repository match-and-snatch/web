module Factories
  module Defaults
    PASSWORD = '$2a$10$8Gk6WhiLCq7wxNh4risWK.04.hvmxRl481fhQId7h1CVopXk/B2.2'.freeze
    PROFILE_PICTURE_URL = 'https://connectpal-uploads.s3.amazonaws.com/profile_pictures/andydean/f17d2ed0cb1d11e3bb32d3ced4f53641____180x180____9646f3e0c76a11e399f355076bd8c6c3____250x250____andyprofile.png'.freeze
    ORIGINAL_PROFILE_PICTURE_URL = PROFILE_PICTURE_URL
    COVER_PICTURE_URL = 'https://connectpal-assets.s3.amazonaws.com/uploads/profile_covers/andydeanradio/2b5dabb0c75a11e3a40a276c3783ecc4____970x606____american-flag-wallpaper.jpg'.freeze
    ORIGINAL_COVER_PICTURE_URL = 'https://connectpal-assets.s3.amazonaws.com/uploads/profile_covers/andydeanradio/2b5dabb0c75a11e3a40a276c3783ecc4____1280x800____american-flag-wallpaper.jpg'.freeze
    SMALL_PROFILE_PICTURE_URL = 'https://connectpal-uploads.s3.amazonaws.com/profile_pictures/andydean/f17d2ed0cb1d11e3bb32d3ced4f53641____50x50____9646f3e0c76a11e399f355076bd8c6c3____250x250____andyprofile.png'.freeze
  end
end

FactoryGirl.define do
  factory :user, aliases: %i[subscriber] do
    sequence(:email) { |n| "user-#{n}@cp.io" }
    sequence(:auth_token) { |n| "auth_token-#{n}" }
    sequence(:api_token) { |n| "api_token-#{n}" }
    sequence(:registration_token) { |n| "registration_token-#{n}" }
    password_hash Factories::Defaults::PASSWORD
    activated true

    trait :admin do
      is_admin true
    end

    trait :sales do
      is_sales true
    end

    trait :with_cc do
      billing_address_city 'Pasadena'
      billing_address_state 'California'
      billing_address_zip '91107'
      billing_address_line_1 '3690 New Haven Rd"'
      billing_address_line_2 ''

      sequence(:stripe_user_id) { |n| "stripe_user_id-#{n}" }
      sequence(:stripe_card_id) { |n| "cc_id-#{n}" }
      sequence(:stripe_card_fingerprint) { |n| "cc_fingerprint-#{n}" }
      last_four_cc_numbers '3333'
      card_type 'American Express'
    end

    trait :with_payout_info do
      holder_name 'Andrew Dean Media, Inc'
      routing_number '111111111'
      account_number '2222222222'
      stripe_recipient_id 'set'
    end

    trait :profile_owner do
      with_payout_info
      with_cc

      is_profile_owner true
      hidden false
      has_mature_content false

      subscribers_count 0

      full_name 'Andy Dean'
      sequence(:slug) { |n| "andydean-#{n}" }
      profile_name 'America Now'
      has_complete_profile true

      subscription_cost 499
      subscription_fees 99
      cost 400

      profile_picture_url Factories::Defaults::PROFILE_PICTURE_URL
      small_profile_picture_url Factories::Defaults::SMALL_PROFILE_PICTURE_URL
      original_profile_picture_url Factories::Defaults::ORIGINAL_PROFILE_PICTURE_URL
      cover_picture_url Factories::Defaults::COVER_PICTURE_URL
      original_cover_picture_url Factories::Defaults::ORIGINAL_COVER_PICTURE_URL
      cover_picture_width 1280
      cover_picture_height 800
      cover_picture_position_perc 12.5

      rss_enabled true
      downloads_enabled true
      itunes_enabled true
      contributions_enabled true
      notifications_debug_enabled true
      subscriptions_chart_visible true
    end
  end
end
