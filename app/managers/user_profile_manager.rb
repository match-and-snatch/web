class UserProfileManager < BaseManager
  include Concerns::CreditCardValidator
  include Concerns::EmailValidator
  include Concerns::PasswordValidator

  attr_reader :user

  SLUG_REGEXP  = /^[a-zA-Z0-9]+(\w|_|-)+[a-zA-Z0-9]+$/i
  COST_REGEXP  = /^\d+(\.\d+)?$/i
  ONLY_DIGITS  = /^[0-9]*$/i

  # @param user [User]
  def initialize(user)
    raise ArgumentError unless user.is_a?(User)
    @user = user
  end

  # @param type [String]
  def add_profile_type(type)
    return if type.blank?
    type = type.squish.titleize
    return if type.blank?
    profile_type = ProfileType.where(['title ILIKE ?', type]).where(user_id: nil).first
    profile_type ||= ProfileType.where(['title ILIKE ?', type]).where(user_id: @user.id).first
    profile_type ||= ProfileType.create!(title: type, user_id: user.id)

    EventsManager.profile_type_added(user: @user, profile_type: profile_type)

    if @user.profile_types.where(id: profile_type.id).empty?
      @user.profile_types << profile_type
    end

    profile_type
  end

  # @param profile_type [ProfileType]
  def remove_profile_type(profile_type)
    raise ArgumentError unless profile_type.is_a?(ProfileType)
    fail_with! profile_type: :not_set unless @user.profile_types.where(id: profile_type.id).any?
    @user.profile_types.delete(profile_type)
    EventsManager.profile_type_removed(user: @user, profile_type: profile_type)
  end

  # @return [User]
  def create_profile_page
    @user.is_profile_owner = true
    @user.save!
    @user
  end

  # @return [User]
  def delete_profile_page
    @user.is_profile_owner = false
    @user.source_subscriptions.find_each do |subscription|
      SubscriptionManager.new(subscriber: subscription.user, subscription: subscription).unsubscribe
    end
    @user.save!
    EventsManager.profile_page_removed(user: @user)
    @user
  end

  # @param cost [Float, String]
  # @param profile_name [String]
  # @param holder_name [String]
  # @param routing_number [String]
  # @param account_number [String]
  # @return [User]
  def update(cost: nil, profile_name: nil, holder_name: nil, routing_number: nil, account_number: nil)
    profile_name   = profile_name.to_s.strip.squeeze(' ')
    holder_name    = holder_name.to_s.strip
    routing_number = routing_number.to_s.strip
    account_number = account_number.to_s.strip

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

    user.cost           = (cost.to_f * 100).to_i
    user.profile_name   = profile_name
    user.holder_name    = holder_name
    user.routing_number = routing_number
    user.account_number = account_number
    user.generate_slug

    save_or_die! user

    EventsManager.profile_created(user: user, data: { cost: cost, profile_name: profile_name })

    sync_stripe_recipient! if user.stripe_recipient_id
    user
  end

  # @param benefits [Array<String>]
  # @return [User]
  def update_benefits(benefits)
    fail_with! :benefits if benefits.nil?

    user.benefits.clear

    benefits.each do |ordering, message|
      user.benefits.create!(message: message, ordering: ordering) if message.present?
    end
    EventsManager.benefits_list_updated(user: user, benefits: user.benefits.map(&:message))

    user
  end

  # @return [User]
  def update_payment_information(holder_name: nil, routing_number: nil, account_number: nil)
    holder_name    = holder_name.to_s.strip
    routing_number = routing_number.to_s.strip
    account_number = account_number.to_s.strip

    validate! do
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

    user.holder_name    = holder_name
    user.routing_number = routing_number
    user.account_number = account_number

    save_or_die! user

    EventsManager.payout_information_changed(user: user)

    sync_stripe_recipient! if user.stripe_recipient_id
    user
  end

  # @param profile_name [String]
  # @return [User]
  def update_profile_name(profile_name)
    profile_name = profile_name.to_s.strip.squeeze(' ')

    fail_with! profile_name: :empty    if profile_name.blank?
    fail_with! profile_name: :too_long if profile_name.length > 140
    fail_with! profile_name: :taken    if (/connect.?pal/i).match(profile_name)

    user.profile_name = profile_name
    save_or_die! user
    EventsManager.profile_name_changed(user: user, name: profile_name)
  end

  # @param cost [Integer, Float, String]
  # @param update_existing_subscriptions [true, false, nil]
  # @return [User]
  def update_cost(cost, update_existing_subscriptions: false)
    validate! { validate_cost cost }

    cost = (cost.to_f * 100).to_i

    if user.source_subscriptions.any?
      if user.cost_change_requests.pending.any?
        fail_with! cost: :pending_request_present
      else
        user.cost_change_requests.create!(old_cost: user.cost,
                                          new_cost: cost,
                                          update_existing_subscriptions: update_existing_subscriptions || false)
        ProfilesMailer.delay.cost_change_request(user, user.subscription_cost, user.pretend(cost: cost).subscription_cost)
        @cost_change_request_submited = true
      end
    else
      change_cost!(cost: cost, update_existing_subscriptions: update_existing_subscriptions)
    end

    user
  end

  def cost_change_request_submited?
    !!@cost_change_request_submited
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
    card = CreditCard.new number: number,
                          cvc: cvc,
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
                     card:      card.to_stripe}

    if user.stripe_user_id
      begin
        customer = Stripe::Customer.retrieve(user.stripe_user_id)
        customer.card     = card.to_stripe
        customer.metadata = metadata
        customer.email    = user.email
        customer = customer.save
      rescue Stripe::InvalidRequestError
        customer = Stripe::Customer.create customer_data
      end
    else
      customer = Stripe::Customer.create customer_data
    end

    card_data = customer['cards']['data'][0]
    user.stripe_user_id = customer['id']
    user.stripe_card_id = card_data['id']
    user.last_four_cc_numbers = card_data['last4']
    user.card_type = card_data['type']
    user.billing_address_zip = card_data['address_zip']
    user.billing_address_line_1 = card_data['address_line1']
    user.billing_address_line_2 = card_data['address_line2']
    user.billing_address_city = card_data['address_city']
    user.billing_address_state = card_data['address_state']

    save_or_die! user

    EventsManager.credit_card_updated(user: user)
    UserManager.new(user).remove_mark_billing_failed
    PaymentManager.new(user: user).perform_test_payment

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

  # @param full_name [String]
  # @param company_name [String]
  # @param email [String]
  # @return [User]
  def update_general_information(full_name: nil, company_name: nil, email: nil)
    full_name = full_name.to_s.strip.squeeze(' ')
    company_name = company_name.to_s.strip.squeeze(' ')

    validate! do
      fail_with full_name: :empty unless full_name.present?
      if company_name
        fail_with company_name: :too_long if company_name.length > 200
      end
      validate_email(email) if email != user.email
    end

    user.full_name    = full_name
    user.company_name = company_name
    user.email        = email

    save_or_die! user
    EventsManager.account_information_changed(user: user, data: { full_name: full_name, company_name: company_name, email: email })
    user
  end

  # @param slug [String]
  # @return [User]
  def update_slug(slug)
    validate! { validate_slug slug }

    user.slug = slug
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

  # @param transloadit_data [Hash]
  # @return [User]
  def update_profile_picture(transloadit_data)
    upload = UploadManager.new(user).create_photo(transloadit_data, template: 'profile_picture')

    user.profile_picture_url = upload.url_on_step('thumb_180x180')
    user.small_profile_picture_url = upload.url_on_step('thumb_50x50')
    user.original_profile_picture_url = upload.url_on_step(':original')

    if user.changes.any?
      save_or_die! user
      EventsManager.profile_picture_changed(user: user, picture: upload)
    end
    user
  end

  def delete_profile_picture
    user.profile_picture_url = nil
    user.small_profile_picture_url = nil
    user.original_profile_picture_url = nil
    save_or_die! user
  end

  # @param transloadit_data [Hash]
  # @return [User]
  def update_cover_picture(transloadit_data)
    upload = UploadManager.new(user).create_photo(transloadit_data, template: 'cover_picture')
    user.cover_picture_position = 0
    user.cover_picture_url = upload.url_on_step('resized')
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

  # @param position [Integer] Y-offset
  def update_cover_picture_position(position)
    user.cover_picture_position = position

    save_or_die! user if user.changes.any?
    user
  end

  # @param transloadit_data [Hash]
  # @return [User]
  def update_welcome_media(transloadit_data)
    mimetype = transloadit_data['uploads'][0]['type']
    upload_manager = UploadManager.new(user)
    upload = if mimetype == 'video'
               upload_manager.create_video(transloadit_data, template: 'welcome_media')
             elsif mimetype == 'audio'
               upload_manager.create_audio(transloadit_data, template: 'welcome_media').first
             end
    clear_old_welcome_uploads!(current_upload: upload)
    EventsManager.welcome_media_added(user: user, media: upload)
    user
  end

  # @return [User]
  def remove_welcome_media!
    clear_old_welcome_uploads!(clear_all: true)
    EventsManager.welcome_media_removed(user: user)
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
      user.source_subscriptions.not_removed.where(rejected: false).been_charged.where(["subscriptions.created_at <= ?", vacation_enabled_at - 1.month]).
        update_all(["charged_at = charged_at + interval '? days'", (Time.zone.now.to_date - vacation_enabled_at.to_date).to_i])

      NotificationManager.delay.notify_vacation_disabled(user)
      EventsManager.vacation_mode_disabled(user: user)
    end
  end

  private

  # @param current_upload [Video, Audio]
  # @param clear_all [Boolean]
  def clear_old_welcome_uploads!(current_upload: nil, clear_all: false)
    if current_upload.present?
      Upload.users.where(uploadable_id: user.id, type: current_upload.class.name).where.not(id: current_upload.id).each do |upload|
        upload.delete
        EventsManager.upload_removed(user: user, upload: upload)
      end
    end
    if clear_all || current_upload.is_a?(Video)
      Audio.users.where(uploadable_id: user.id).each do |audio|
        audio.delete
        EventsManager.upload_removed(user: user, upload: audio)
      end
    end
    if clear_all || current_upload.is_a?(Audio)
      Video.users.where(uploadable_id: user.id).each do |video|
        video.delete
      end
    end
  end

  def sync_stripe_recipient!
    stripe_recipient = Stripe::Recipient.retrieve(recipient.stripe_id)
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
    User.where.not(id: user.id).where(slug: slug).any?
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

  def update_subscriptions_cost
    user.source_subscriptions.update_all({ cost: user.cost,
                                           fees: user.subscription_fees,
                                           total_cost: user.subscription_cost })
  end
end
