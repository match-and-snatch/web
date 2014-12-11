class UserDecorator < BaseDecorator
  delegate :slug, :email, :full_name, :profile_name,
           :complete_profile?, :profile_disabled?,
           :has_cc_payment_account?, :subscribed_to?,
           :original_profile_picture_url, :profile_picture_url, :small_profile_picture_url,
           :original_account_picture_url, :account_picture_url, :small_account_picture_url,
           :comment_picture_url,
           :cover_picture_url, :original_cover_picture_url, :id,
           :contacts_info,
           :rss_enabled?,
           :itunes_enabled?,
           :downloads_enabled?,
           :cover_picture_position,
           :cost, :name, :has_profile_page?,
           :posts, :source_uploads, :account_number, :holder_name, :routing_number,
           :vacation_enabled?,
           :last_visited_profile,
           to: :object

  # @param object [User]
  def initialize(object)
    @object = object
  end

  def profile_types
    object.profile_types.order('profile_types_users.ordering')
  end

  # Returns profile types string
  # @return [String]
  def types
    @types ||= profile_types.pluck(:title).join('&nbsp;/&nbsp;').html_safe
  end

  def types_text
    types.blank? ? 'Add Profile Type' : types
  end

  def created_at
    object.created_at
  end

  def to_param
    object.slug
  end

  def cc_placeholder
    "XXXX-XXXX-XXXX-#{object.last_four_cc_numbers}"
  end

  # @return [Video, nil]
  def welcome_video
    @welcome_video ||= object.welcome_video
  end

  # @return [Audio, nil]
  def welcome_audio
    @welcome_audio ||= object.welcome_audio
  end

  # @return [Audio, Video, nil]
  def welcome_media
    @welcome_media ||= welcome_video || welcome_audio
  end

  def subscriptions_count
    @subscriptions_count ||= subscriptions.count
  end

  protected

  def subscriptions
    Subscription.not_removed.joins(:user).where({users: {billing_failed: false}}).where(target_user_id: object.id)
  end
end
