class CurrentUserDecorator < BaseDecorator
  delegate :slug, :email, :complete_profile?, :has_cc_payment_account?, :subscribed_to?, to: :object

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
      when :see_profile          then subject.id == object.id ||                 subscribed_to?(subject)
      else
        raise ArgumentError, "No such action #{action}"
      end
    else
      raise ArgumentError, "No such subject #{subject.inspect}"
    end
  end

  # @return [String]
  def authorization_status_message
    if authorized?
      "Hi, <b>#{object.first_name}</b>!".html_safe
    end
  end
end
