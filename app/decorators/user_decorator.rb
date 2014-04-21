class UserDecorator < BaseDecorator
  delegate :slug, :email, :full_name, :profile_name,
           :profile_types,
           :complete_profile?, :profile_disabled?,
           :has_cc_payment_account?, :subscribed_to?,
           :original_profile_picture_url, :profile_picture_url,
           :cover_picture_url, :original_cover_picture_url, :id,
           :contacts_info,
           :cover_picture_position,
           :cost, :name, :has_profile_page?,
           to: :object

  # @param object [User]
  def initialize(object)
    @object = object
  end
end
