class CurrentUserDecorator < BaseDecorator
  delegate :slug, :email, :has_complete_profile?, :has_incomplete_profile?, :has_cc_payment_account?, :subscribed_to?,
           :original_profile_picture_url, :profile_picture_url,
           :cover_picture_url, :original_cover_picture_url,
           to: :object

  # @param user [User, nil]
  def initialize(user = nil)
    @object = user || User.new
  end

  def authorized?
    !object.new_record?
  end

  # @param action [Symbol]
  # @param subject
  # @raise [ArgumentError] if action or subject are not registered
  # @return [true, false]
  def can?(action, subject)
    case subject
    when User
    case action
    when :subscribe_to         then subject.id != object.id && authorized? && !subscribed_to?(subject)
    when :see_subscribe_button then subject.id != object.id &&                !subscribed_to?(subject)
    when :see                  then subject.id == object.id ||                 subscribed_to?(subject)
    when :manage               then subject.id == object.id
    else
      raise ArgumentError, "No such action #{action}"
    end
    when Comment
    case action
    when :delete then subject.user_id == object.id || subject.post_user_id == object.id
    end
    when Post
    case action
    when :see then object.id == subject.user.id || subscribed_to?(subject.user)
    end
    else
      raise ArgumentError, "No such subject #{subject.inspect}"
    end
  end

  def has_subscriptions?
    object.subscriptions.any?
  end
end
