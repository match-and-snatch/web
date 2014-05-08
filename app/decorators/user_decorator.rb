class UserDecorator < BaseDecorator
  delegate :slug, :email, :full_name, :profile_name,
           :profile_types,
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
           to: :object

  # @param object [User]
  def initialize(object)
    @object = object
  end

  # Returns profile types string
  # @return [String]
  def types
    @types ||= object.profile_types.pluck(:title).join('&nbsp;/&nbsp;').html_safe
  end

  def types_text
    types.blank? ? 'Add Profile Type' : types
  end

  def to_param
    object.slug
  end
end
