class UserProfileManager < BaseManager
  include Concerns::CreditCardValidator
  include Concerns::EmailValidator
  include Concerns::PasswordValidator
  include Concerns::CostUpdatePerformer
  include Concerns::WelcomeMediaHandler
  include Concerns::SubscriberBenefitsHandler
  include Concerns::NameValidator

  attr_reader :user, :performer

  SLUG_REGEXP  = /^[a-zA-Z0-9]+(\w|_|-)+[a-zA-Z0-9]+$/i
  COST_REGEXP  = /^\d+(\.\d+)?$/i
  ONLY_DIGITS  = /^[0-9]*$/i

  # @param user [User]
  # @param performer [User]
  def initialize(user, performer = user)
    raise ArgumentError unless user.is_a?(User)
    raise ArgumentError unless performer.is_a?(User)
    @user = user
    @performer = performer
  end

  # @param type [String]
  def add_profile_type(type)
    return if type.blank?
    type = type.squish.gsub(/\b(.)/) { $1.upcase }
    return if type.blank?
    profile_type = ProfileType.where(['title ILIKE ?', type]).where(user_id: nil).first
    profile_type ||= ProfileType.where(['title ILIKE ?', type]).where(user_id: @user.id).first
    profile_type ||= ProfileType.create!(title: type, user_id: user.id)

    EventsManager.profile_type_added(user: @user, profile_type: profile_type)

    if @user.profile_types.where(id: profile_type.id).empty?
      @user.profile_types << profile_type
    end

    reindex_profile

    profile_type
  end

  # @param profile_type [ProfileType]
  def remove_profile_type(profile_type)
    raise ArgumentError unless profile_type.is_a?(ProfileType)
    fail_with! profile_type: :not_set unless @user.profile_types.where(id: profile_type.id).any?
    @user.profile_types.delete(profile_type)
    reindex_profile
    EventsManager.profile_type_removed(user: @user, profile_type: profile_type)
  end

  # @param ids [Array]
  def reorder_profile_types(ids)
    ids.each_with_index do |id, index|
      @user.profile_types_users.where(profile_type_id: id).update_all(ordering: index)
    end
  end

  # Hides/shows users in search results
  def toggle
    @user.hidden = !@user.hidden
    @user.save!
    reindex_profile
  end

  # Displays warning to unsubscribed users
  def toggle_mature_content
    @user.has_mature_content = !@user.has_mature_content
    @user.save!
    reindex_profile
  end

  # @return [User]
  def create_profile_page
    @user.delete_profile_page_requests.pending.each do |request|
      request.reject!
    end
    @user.is_profile_owner = true
    @user.save!
    reindex_profile
  end

  # @return [User]
  def delete_profile_page
    if user.source_subscriptions.active.any?
      if user.delete_profile_page_requests.pending.any?
        fail_with! 'You currently have a pending request to delete profile page.'
      else
        user.delete_profile_page_requests.create!
        ProfilesMailer.delay.delete_profile_page_request(user)
        @delete_profile_page_request_submitted = true
      end
    else
      delete_profile_page!
    end

    user
  end

  def delete_profile_page!(delete_profile_page_request = nil)
    if user.is_profile_owner?
      user.is_profile_owner = false
      user.source_subscriptions.includes(:user, :target_user, :target).not_removed.find_each do |subscription|
        SubscriptionManager.new(subscriber: subscription.user, subscription: subscription).unsubscribe(log_subscriptions_count: false)
      end
      UserStatsManager.new(user).log_subscriptions_count
      user.save!
      reindex_profile
      EventsManager.profile_page_removed(user: user)
      delete_profile_page_request.try(:approve!)
    end
  end

  def delete_profile_page_request_submitted?
    !!@delete_profile_page_request_submitted
  end

  # @param cost [Float, String]
  # @param profile_name [String]
  # @param holder_name [String]
  # @param routing_number [String]
  # @param account_number [String]
  # @return [User]
  def finish_owner_registration(*args)
    never_passed_second_step = !user.passed_profile_steps?
    update(*args).tap { send_welcome_email if never_passed_second_step && !user.cost_change_request }
  end

  # @return [User]
  def update_payment_information(holder_name: nil, routing_number: nil, account_number: nil, prefer_paypal: false, paypal_email: nil)
    holder_name    = holder_name.to_s.strip
    routing_number = routing_number.to_s.strip
    account_number = account_number.to_s.strip
    paypal_email   = paypal_email.to_s.strip

    validate! do
      if prefer_paypal
        validate_email(paypal_email, email_confirmation: paypal_email, check_if_taken: false, field_name: :paypal_email)
      else
        fail_with holder_name: :empty if holder_name.blank?

        if routing_number.match ONLY_DIGITS
          fail_with routing_number: :not_a_routing_number if routing_number.try(:length) != 9
        else
          fail_with routing_number: :not_an_integer
        end

        if account_number.match ONLY_DIGITS
          fail_with account_number: :not_an_account_number unless (3..20).include?(account_number.try(:length))
        else
          fail_with account_number: :not_an_integer
        end
      end
    end

    user.holder_name    = holder_name.try(:strip)
    user.routing_number = routing_number.try(:strip)
    user.account_number = account_number.try(:strip)
    user.paypal_email   = paypal_email.try(:strip)
    user.prefers_paypal = prefer_paypal || false
    user.payout_updated_at = Time.zone.now

    save_or_die! user

    EventsManager.payout_information_changed(user: user)

    sync_stripe_recipient! if user.stripe_recipient_id
    user
  end

  # @param profile_name [String]
  # @return [User]
  def update_profile_name(profile_name)
    fail_with! 'You can\'t change profile name' if !performer.admin? && user.gross_threshold_reached?

    profile_name = profile_name.to_s.strip.squeeze(' ')

    fail_with! profile_name: :empty    if profile_name.blank?
    fail_with! profile_name: :too_long if profile_name.length > 140
    fail_with! profile_name: :taken    if (/connect.?pal/i).match(profile_name)

    user.profile_name = profile_name.try(:strip)
    save_or_die! user
    reindex_user
    EventsManager.profile_name_changed(user: user, name: profile_name)
  end

  # @param cost [Integer, Float, String] in dollars
  # @param update_existing_subscriptions [true, false, nil]
  # @return [User]
  def update_cost(cost, update_existing_subscriptions: false)
    validate! { validate_cost cost }

    cost = (cost.to_f * 100).to_i

    if user.source_subscriptions.any? || cost >= CostChangeRequest::MAX_COST
      create_cost_change_request(cost: cost, update_existing_subscriptions: update_existing_subscriptions)
    else
      user.cost_change_request.try(:reject!)
      change_cost!(cost: cost, update_existing_subscriptions: update_existing_subscriptions)
      send_welcome_email if user.cost_change_request.try(:completes_profile?)
    end

    user
  end

  def cost_change_request_submitted?
    !!@cost_change_request_submitted
  end

  # @param cost [Integer]
  # @param update_existing_subscriptions [Boolean]
  def change_cost!(cost: , update_existing_subscriptions: false)
    previous_cost = user.cost
    user.cost = cost
    user.cost_changed_at = Time.zone.now
    save_or_die! user

    update_subscriptions_cost if update_existing_subscriptions
    EventsManager.subscription_cost_changed(user: user, from: previous_cost, to: cost)
  end

  # @param contacts_info [Hash]
  # @return [User]
  def update_contacts_info(contacts_info)
    raise ArgumentError unless contacts_info.is_a?(Hash)

    user.contacts_info = {}.tap do |info|
      contacts_info.each do |provider, url|
        if url.present?
          info[provider] = (url =~ /^https?:\/\//) ? url : "http://#{url}"
        end
      end
    end

    save_or_die! user
    EventsManager.contact_info_changed(user: user, info: user.contacts_info)
    user
  end

  # @param stripe_token [String]
  # @param expiry_month [String]
  # @param expiry_year [String]
  # @param address_line_1 [String]
  # @param address_line_2 [String]
  # @param state [String]
  # @param city [String]
  # @param zip [String]
  # @return [User]
  def pull_cc_data(stripe_token: nil, expiry_month: nil, expiry_year: nil,
                   address_line_1: nil, address_line_2: nil, state: nil, city: nil, zip: nil)
    fail_with! "You can't update your credit card since your current one was declined" if user.cc_declined?

    if APP_CONFIG['enable_cc_locks']
      UserManager.new(user).lock(type: :billing, reason: :cc_update_limit) if user.credit_card_update_requests.recent.count >= 3
    end

    fail_locked! if user.locked?

    card = CreditCard.new stripe_token: stripe_token,
                          holder_name: user.full_name,
                          expiry_month: expiry_month,
                          expiry_year: expiry_year,
                          address_line_1: address_line_1,
                          address_line_2: address_line_2,
                          state: state,
                          city: city,
                          zip: zip

    validate! { validate_cc card, sensitive: false }
    fail_with!({stripe_token: :empty}, MissingCcTokenError) unless card.registered?

    metadata = {user_id: user.id, full_name: user.full_name}
    customer_data = {metadata: metadata, email: user.email, source: stripe_token}

    if user.stripe_user_id
      begin
        customer = Stripe::Customer.retrieve(user.stripe_user_id)
        customer.source = stripe_token
        customer.metadata = metadata
        customer.email = user.email
        customer = customer.save
      rescue Stripe::InvalidRequestError
        customer = Stripe::Customer.create customer_data
      end
    else
      customer = Stripe::Customer.create customer_data
    end

    card_data = customer['sources']['data'][0]
    cc_fingerprint = card_data['fingerprint']

    user.stripe_user_id = customer['id']
    user.stripe_card_id = card_data['id']
    user.stripe_card_fingerprint = cc_fingerprint
    user.last_four_cc_numbers = card_data['last4']
    user.card_type = card_data['type']
    user.billing_address_zip = card_data['address_zip']
    user.billing_address_line_1 = card_data['address_line1']
    user.billing_address_line_2 = card_data['address_line2']
    user.billing_address_city = card_data['address_city']
    user.billing_address_state = card_data['address_state']
    user.billing_address_country = card_data['address_country']

    save_or_die! user

    user.credit_card_update_requests.create!(approved: true, performed: true)
    EventsManager.credit_card_updated(user: user)

    if APP_CONFIG['enable_cc_locks']
      card_already_used_by_another_account = User.where(stripe_card_fingerprint: cc_fingerprint).
        where("users.id <> ?", user.id).
        any?
    end

    if card_already_used_by_another_account
      UserManager.new(user).lock(type: :billing, reason: :cc_used_by_another_account)
    else
      UserManager.new(user).remove_mark_billing_failed
      PaymentManager.new(user: user).perform_test_payment
    end

    user
  rescue Stripe::CardError => e
    err = e.json_body[:error]

    case err[:code]
    when 'incorrect_number', 'invalid_number', 'card_declined', 'missing', 'processing_error'
      fail_with! number: err[:message]
    when 'invalid_expiry_month', 'invalid_expiry_year', 'expired_card'
      fail_with! expiry_date: err[:message]
    when 'invalid_cvc', 'incorrect_cvc'
      fail_with! cvc: err[:message]
    when 'incorrect_zip'
      fail_with! zip: :invalid_zip
    else
      fail_with! number: err[:code]
    end
  rescue Stripe::InvalidRequestError
    fail_with! number: 'Invalid stripe request'
  rescue Stripe::AuthenticationError
    fail_with! number: 'Stripe auth error'
  rescue Stripe::APIConnectionError
    fail_with! number: 'Stripe API connection error'
  rescue Stripe::StripeError
    fail_with! number: 'Generic Stripe error'
  end

  # @param number [String]
  # @param cvc [String]
  # @param expiry_month [String]
  # @param expiry_year [String]
  # @param address_line_1 [String]
  # @param address_line_2 [String]
  # @param state [String]
  # @param city [String]
  # @param zip [String]
  # @return [User]
  def update_cc_data(number: nil, cvc: nil, expiry_month: nil, expiry_year: nil,
                     address_line_1: nil, address_line_2: nil, state: nil, city: nil, zip: nil)
    fail_with! "You can't update your credit card since your current one was declined" if user.cc_declined?

    UserManager.new(user).lock(type: :billing, reason: :cc_update_limit) if user.credit_card_update_requests.recent.count >= 3
    fail_locked! if user.locked?

    card = CreditCard.new number: number,
                          cvc: cvc,
                          holder_name: user.full_name,
                          expiry_month: expiry_month,
                          expiry_year: expiry_year,
                          address_line_1: address_line_1,
                          address_line_2: address_line_2,
                          state: state,
                          city: city,
                          zip: zip

    validate! { validate_cc card }

    metadata      = {user_id:   user.id,
                     full_name: user.full_name}
    customer_data = {metadata:  metadata,
                     email:     user.email,
                     source:    card.to_stripe}

    if user.stripe_user_id
      begin
        customer = Stripe::Customer.retrieve(user.stripe_user_id)
        customer.source   = card.to_stripe
        customer.metadata = metadata
        customer.email    = user.email
        customer = customer.save
      rescue Stripe::InvalidRequestError
        customer = Stripe::Customer.create customer_data
      end
    else
      customer = Stripe::Customer.create customer_data
    end

    card_data = customer['sources']['data'][0]
    cc_fingerprint = card_data['fingerprint']

    user.stripe_user_id = customer['id']
    user.stripe_card_id = card_data['id']
    user.stripe_card_fingerprint = cc_fingerprint
    user.last_four_cc_numbers = card_data['last4']
    user.card_type = card_data['type']
    user.billing_address_zip = card_data['address_zip']
    user.billing_address_line_1 = card_data['address_line1']
    user.billing_address_line_2 = card_data['address_line2']
    user.billing_address_city = card_data['address_city']
    user.billing_address_state = card_data['address_state']
    user.billing_address_country = card_data['address_country']

    save_or_die! user

    user.credit_card_update_requests.create!(approved: true, performed: true)
    EventsManager.credit_card_updated(user: user)

    card_already_used_by_another_account = User.where(stripe_card_fingerprint: cc_fingerprint).
      where("(users.id <> ?) AND NOT (users.locked = 't' AND users.lock_type = 'billing')", user.id).
      any?

    if card_already_used_by_another_account
      UserManager.new(user).lock(type: :billing, reason: :cc_used_by_another_account)
    else
      UserManager.new(user).remove_mark_billing_failed
      PaymentManager.new(user: user).perform_test_payment
    end

    user
  rescue Stripe::CardError => e
    err = e.json_body[:error]

    case err[:code]
    when 'incorrect_number', 'invalid_number', 'card_declined', 'missing', 'processing_error'
      fail_with! number: err[:message]
    when 'invalid_expiry_month', 'invalid_expiry_year', 'expired_card'
      fail_with! expiry_date: err[:message]
    when 'invalid_cvc', 'incorrect_cvc'
      fail_with! cvc: err[:message]
    when 'incorrect_zip'
      fail_with! zip: :invalid_zip
    else
      fail_with! number: err[:code]
    end
  rescue Stripe::InvalidRequestError
    fail_with! number: 'Invalid stripe request'
  rescue Stripe::AuthenticationError
    fail_with! number: 'Stripe auth error'
  rescue Stripe::APIConnectionError
    fail_with! number: 'Stripe API connection error'
  rescue Stripe::StripeError
    fail_with! number: 'Generic Stripe error'
  end

  # @return [User]
  def delete_cc_data!
    fail_locked! if user.locked?
    fail_with! "You can't remove your billing information since you have active subscriptions" if user.subscriptions.active.any?

    cc_data = {}.tap do |data|
      data[:stripe_user_id] = user.stripe_user_id
      data[:stripe_card_id] = user.stripe_card_id
      data[:stripe_card_fingerprint] = user.stripe_card_fingerprint
      data[:last_four_cc_numbers] = user.last_four_cc_numbers
      data[:card_type] = user.card_type
      data[:billing_address_zip] = user.billing_address_zip
      data[:billing_address_line_1] = user.billing_address_line_1
      data[:billing_address_line_2] = user.billing_address_line_2
      data[:billing_address_city] = user.billing_address_city
      data[:billing_address_state] = user.billing_address_state
      data[:billing_address_country] = user.billing_address_country
    end

    # user.stripe_user_id = nil
    user.stripe_card_id = nil
    user.stripe_card_fingerprint = nil
    user.last_four_cc_numbers = nil
    user.card_type = nil
    user.billing_address_zip = nil
    user.billing_address_line_1 = nil
    user.billing_address_line_2 = nil
    user.billing_address_city = nil
    user.billing_address_state = nil
    user.billing_address_country = nil

    save_or_die! user

    if cc_data[:stripe_user_id]
      customer = Stripe::Customer.retrieve(cc_data[:stripe_user_id])
      customer.sources.retrieve(cc_data[:stripe_card_id]).delete rescue nil
    end

    user.contributions.recurring.each do |contribution|
      ContributionManager.new(user: user, contribution: contribution).delete
    end

    EventsManager.credit_card_removed(user: user, data: cc_data)
    UserManager.new(user).remove_mark_billing_failed

    user
  end

  def decline_credit_card
    fail_with! email: 'Already declined' if @user.cc_declined?

    if @user.stripe_card_fingerprint.present?
      fingerprint = @user.stripe_card_fingerprint
    else
      customer = Stripe::Customer.retrieve(@user.stripe_user_id)
      card = customer.sources.retrieve(@user.stripe_card_id)
      fingerprint = card.fingerprint
      @user.stripe_card_fingerprint = fingerprint
      @user.save!
    end

    CreditCardDecline.create!(stripe_fingerprint: fingerprint, user_id: @user.id)
    EventsManager.credit_card_declined(user: @user, data: { email: @user.email, stripe_fingerprint: fingerprint })
  end

  def restore_credit_card
    fail_with! email: 'Not declined' unless @user.cc_declined?

    @user.credit_card_declines.each do |decline|
      decline.destroy
      EventsManager.credit_card_restored(user: @user, data: { email: @user.email, stripe_fingerprint: decline.stripe_fingerprint })
    end
  end

  # @param full_name [String]
  # @param company_name [String]
  # @param email [String]
  # @return [User]
  def update_general_information(full_name: nil, company_name: nil, email: nil)
    full_name = full_name.to_s.strip.squeeze(' ')
    company_name = company_name.to_s.strip.squeeze(' ')
    email = email.try(:downcase)
    old_email = user.email

    validate! do
      validate_account_name(full_name)
      validate_name_length(company_name, field_name: :company_name)
      validate_email(email, email_confirmation: email) if email != old_email
    end

    user.full_name    = full_name.try(:strip)
    user.company_name = company_name.try(:strip)
    user.email        = email

    if email != old_email
      user.old_email = old_email
      user.email_updated_at = Time.zone.now
    end

    save_or_die! user
    reindex_user
    EventsManager.account_information_changed(user: user, data: { full_name: full_name,
                                                                  company_name: company_name,
                                                                  old_email: old_email,
                                                                  email: email })
    user
  end

  # @param slug [String]
  # @return [User]
  def update_slug(slug)
    fail_with! 'You can\'t update your profile page url' if !performer.admin? && user.gross_threshold_reached?

    validate! { validate_slug slug }

    user.slug = slug.parameterize
    save_or_die! user
    EventsManager.slug_changed(user: user, slug: slug)
    user
  end

  # @param transloadit_data [Hash]
  # @return [User]
  def update_account_picture(transloadit_data)
    upload = UploadManager.new(user).create_photo(transloadit_data, template: 'profile_picture')

    user.account_picture_url = upload.url_on_step('thumb_180x180')
    user.small_account_picture_url = upload.url_on_step('thumb_50x50')
    user.original_account_picture_url = upload.url_on_step(':original')

    if user.changes.any?
      save_or_die! user
      EventsManager.account_photo_changed(user: user, photo: upload)
    end
    user
  end

  def delete_account_picture
    user.account_picture_url = nil
    user.small_account_picture_url = nil
    user.original_account_picture_url = nil
    save_or_die! user
  end

  # @param transloadit_data [Hash]
  # @return [User]
  def update_profile_picture(transloadit_data)
    upload = UploadManager.new(user).create_photo(transloadit_data, template: 'profile_picture')

    user.profile_picture_url = upload.url_on_step('thumb_180x180')
    user.small_profile_picture_url = upload.url_on_step('thumb_50x50')
    user.original_profile_picture_url = upload.url_on_step(':original')

    if user.changes.any?
      save_or_die! user
      reindex_profile
      EventsManager.profile_picture_changed(user: user, picture: upload)
    end
    user
  end

  def delete_profile_picture
    user.profile_picture_url = nil
    user.small_profile_picture_url = nil
    user.original_profile_picture_url = nil
    save_or_die! user
    reindex_profile
  end

  # @param transloadit_data [Hash]
  # @return [User]
  def update_cover_picture(transloadit_data)
    upload = UploadManager.new(user).create_photo(transloadit_data, template: 'cover_picture')
    user.cover_picture_position = 0
    user.cover_picture_position_perc = 0
    user.cover_picture_url = upload.url_on_step('resized')
    user.cover_picture_width = upload.attr_on_step('resized', 'meta')['width']
    user.cover_picture_height = upload.attr_on_step('resized', 'meta')['height']
    user.original_cover_picture_url = upload.url_on_step(':original')

    if user.changes.any?
      save_or_die! user
      EventsManager.cover_picture_changed(user: user, picture: upload)
    end
    user
  end

  def delete_cover_picture
    user.cover_picture_position = 0
    user.cover_picture_url = nil
    user.original_cover_picture_url = nil
    save_or_die! user
  end

  # @param position_perc [Integer] Y-offset in %
  def update_cover_picture_position(position_perc)
    user.cover_picture_position_perc = position_perc

    save_or_die! user if user.changes.any?
    user
  end

  # @param current_password [String]
  # @param new_password [String]
  # @param new_password_confirmation [String]
  # @return [User]
  def change_password(current_password: nil, new_password: nil, new_password_confirmation: nil)
    AuthenticationManager.new(email: user.email,
                              password: current_password,
                              password_confirmation: current_password).authenticate
    validate! do
      validate_password password:              new_password,
                        password_confirmation: new_password_confirmation,
                        password_field_name:              :new_password,
                        password_confirmation_field_name: :new_password_confirmation
    end

    user.set_new_password(new_password)
    save_or_die! user
    EventsManager.password_changed(user: user)
    user
  rescue AuthenticationError
    fail_with! :current_password
  end

  def make_profile_public
    fail_with! 'Profile is already public' if @user.has_public_profile

    user.has_public_profile = true
    save_or_die! user
  end

  def make_profile_private
    fail_with! 'Profile is already private' unless @user.has_public_profile

    @user.has_public_profile = false
    save_or_die! user
  end

  def toggle_accepting_large_contributions
    @user.accepts_large_contributions = !@user.accepts_large_contributions
    save_or_die! @user
  end

  def enable_contributions
    @user.contributions_enabled = true
    save_or_die! user
  end

  def disable_contributions
    @user.contributions_enabled = false
    save_or_die! user
  end

  def enable_notifications_debug
    @user.notifications_debug_enabled = true
    save_or_die! user
  end

  def disable_notifications_debug
    @user.notifications_debug_enabled = false
    save_or_die! user
  end

  def enable_rss
    fail_with! 'RSS is already enabled' if @user.rss_enabled?
    @user.rss_enabled = true
    save_or_die! user
  end

  def disable_rss
    fail_with! 'RSS is not enabled' unless @user.rss_enabled?
    @user.rss_enabled = false
    save_or_die! user
  end

  def enable_downloads
    fail_with! 'Downloads feature is already enabled' if @user.downloads_enabled?
    @user.downloads_enabled = true
    save_or_die! user
  end

  def disable_downloads
    fail_with! 'Downloads feature is not enabled' unless @user.downloads_enabled?
    @user.downloads_enabled = false
    save_or_die! user
  end

  def enable_itunes
    fail_with! 'iTunes feature is already enabled' if @user.itunes_enabled?
    @user.itunes_enabled = true
    save_or_die! user
  end

  def disable_itunes
    fail_with! 'iTunes feature is not enabled' unless @user.itunes_enabled?
    @user.itunes_enabled = false
    save_or_die! user
  end

  def enable_message_notifications
    fail_with! 'Message notifications already turned on' if @user.message_notifications_enabled?
    @user.message_notifications_enabled = true
    save_or_die! user
  end

  def disable_message_notifications
    fail_with! 'Message notifications already turned off' unless @user.message_notifications_enabled?
    @user.message_notifications_enabled = false
    save_or_die! user
  end

  # @param reason [String]
  def enable_vacation_mode(reason: )
    fail_with! 'Vacation Mode is already enabled' if user.vacation_enabled?
    fail_with! vacation_message: :empty if reason.blank?

    user.vacation_enabled = true
    user.vacation_enabled_at = Time.zone.now
    user.vacation_message = reason

    save_or_die!(user).tap do
      NotificationManager.delay.notify_vacation_enabled(user)
      EventsManager.vacation_mode_enabled(user: user, reason: reason)
    end
  end

  def disable_vacation_mode
    fail_with! 'Vacation Mode is not enabled' unless user.vacation_enabled?

    vacation_enabled_at = user.vacation_enabled_at

    user.vacation_enabled = false
    user.vacation_enabled_at = nil
    user.vacation_message = nil

    save_or_die!(user).tap do
      # Charge users who have been subscribed for more than 1 month
      affected_users_count = user.source_subscriptions
                                 .not_removed
                                 .where(rejected: false)
                                 .been_charged
                                 .where(["subscriptions.created_at <= ?", vacation_enabled_at - 1.month])
                                 .update_all(["charged_at = charged_at + interval '? days'", (Time.zone.now.to_date - vacation_enabled_at.to_date).to_i])

      NotificationManager.delay.notify_vacation_disabled(user)
      EventsManager.vacation_mode_disabled(user: user, affected_users_count: affected_users_count)
    end
  end

  # @param partner [User]
  # @param partner_fees [Integer]
  # @return [User]
  def set_partner!(partner: , partner_fees: )
    raise ArgumentError unless partner.is_a?(User)

    validate_partner_fees! partner_fees

    user.partner = partner
    user.partner_fees = partner_fees.to_f * 100
    save_or_die!(user)
  end

  # @return [User]
  def remove_partner!
    user.partner = nil
    user.partner_fees = 0
    save_or_die!(user)
  end

  private

  # @overload
  def email_taken?(email = nil)
    User.by_email(email).where('(users.id <> ?) AND (activated = ? OR is_admin = ?)', user.id, true, true).any? || APP_CONFIG['admins'].include?(email.try(:downcase))
  end

  def reindex_profile
    if user.publicly_visible?
      user.elastic_index_document(type: 'profiles')
    else
      user.elastic_delete_document(type: 'profiles')
    end
    user
  end

  def reindex_user
    user.elastic_index_document
    user
  end

  def sync_stripe_recipient!
    stripe_recipient = Stripe::Recipient.retrieve(@user.stripe_recipient_id)
    stripe_recipient.name = @user.holder_name
    stripe_recipient.type = 'individual'
    stripe_recipient.bank_account = @user.bank_account_data
    stripe_recipient.email = @user.email
    stripe_recipient.description = @user.description
    stripe_recipient.save
  end

  # @param slug [String]
  # @return [true, false]
  def slug_taken?(slug)
    User.where.not(id: user.id).where(slug: slug.parameterize).any?
  end

  def validate_slug(slug)
    return fail_with slug: :empty          if slug.blank?
    return fail_with slug: :not_a_slug unless slug.match SLUG_REGEXP
    return fail_with slug: :taken          if slug_taken?(slug)
  end

  def validate_cost(cost)
    if cost.blank?
      fail_with cost: :empty
    elsif !cost.to_s.strip.match COST_REGEXP
      fail_with cost: :not_a_cost
    elsif (cost.to_f - cost.to_i) != 0
      fail_with cost: :not_a_whole_number
    elsif (cost.to_f * 100).to_i <= 0
      fail_with cost: :zero
    elsif (cost.to_f * 100).to_i > 999999
      fail_with cost: :reached_maximum
    end
  end

  def validate_partner_fees!(amount)
    field = :partner_fees

    if amount.blank?
      fail_with! field => :empty
    elsif !amount.to_s.strip.match COST_REGEXP
      fail_with! field => :not_a_money
    elsif amount.to_f.zero?
      fail_with! field => :zero
    elsif (amount.to_f * 100).to_i > 999999
      fail_with! field => :reached_maximum
    elsif (amount.to_f * 100).to_i > @user.cost.to_i
      fail_with! field => :reached_maximum
    end
  end

  def update_subscriptions_cost
    user.source_subscriptions.update_all({ cost: user.cost,
                                           fees: user.subscription_fees,
                                           total_cost: user.subscription_cost })
  end

  def create_cost_change_request(cost: , update_existing_subscriptions: )
    if user.cost_change_request
      fail_with! cost: :pending_request_present
    else
      user.cost_change_requests.create!(old_cost: user.current_cost,
                                        new_cost: cost,
                                        update_existing_subscriptions: update_existing_subscriptions || false)
      ProfilesMailer.delay.cost_change_request(user, user.subscription_cost, user.pretend(cost: cost).subscription_cost)
      @cost_change_request_submitted = true
    end
  end

  def send_welcome_email
    AuthMailer.delay.registered(user) if user.cost_approved?
  end

  # Registration, step 2
  # @param cost [Float, String]
  # @param profile_name [String]
  # @param holder_name [String]
  # @param routing_number [String]
  # @param account_number [String]
  # @return [User]
  def update(cost: nil, profile_name: nil, holder_name: nil, routing_number: nil, account_number: nil)
    fail_with! 'You have active subscribers' if user.subscribers_count > 0

    profile_name   = profile_name.to_s.strip.squeeze(' ')
    holder_name    = holder_name.to_s.strip
    routing_number = routing_number.to_s.strip
    account_number = account_number.to_s.strip

    never_passed_second_step = !user.passed_profile_steps?

    validate! do
      if profile_name.blank?
        fail_with profile_name: :empty
      elsif profile_name.length > 140
        fail_with profile_name: :too_long
      else
        fail_with profile_name: :taken if (/connect.?pal/i).match(profile_name)
      end

      validate_cost cost

      if holder_name.present? || routing_number.present? || account_number.present?
        fail_with holder_name: :empty if holder_name.blank?

        if routing_number.match ONLY_DIGITS
          fail_with routing_number: :not_a_routing_number if routing_number.try(:length) != 9
        else
          fail_with routing_number: :not_an_integer
        end

        if account_number.match ONLY_DIGITS
          fail_with account_number: :not_an_account_number unless (3..20).include?(account_number.try(:length))
        else
          fail_with account_number: :not_an_integer
        end
      end
    end

    new_cost = (cost.to_f * 100).to_i
    if new_cost >= CostChangeRequest::MAX_COST
      user.cost = nil
      user.subscription_fees = nil
      user.subscription_cost = nil
      create_cost_change_request(cost: new_cost, update_existing_subscriptions: false)
    else
      user.cost_change_request.try(:reject!)
    end
    user.cost           = new_cost
    user.profile_name   = profile_name.try(:strip)
    user.holder_name    = holder_name.try(:strip)
    user.routing_number = routing_number.try(:strip)
    user.account_number = account_number.try(:strip)
    user.generate_slug(force: true)

    save_or_die! user

    reindex_user
    EventsManager.profile_created(user: user, data: { cost: cost, profile_name: profile_name }) if never_passed_second_step

    sync_stripe_recipient! if user.stripe_recipient_id
    user
  end
end
