class ProfileDecorator < UserDecorator

  # @param user [User]
  def initialize(user)
    raise ArgumentError unless user.is_a? User
    @object = user
  end

  # @return [Array<String>]
  def benefits
    @benefits ||= @object.benefits.order(:ordering)
  end

  # @return [Array<String>]
  def benefit_messages
    (benefits.map(&:message) + 10.times.map {}).first(10)
  end

  # @return [Hash]
  def contacts_info
    @contacts_info ||= @object.contacts_info
  end


  # @return [Integer, Float]
  def subscription_cost
    @subscription_cost ||= begin
      cost = object.subscription_cost.to_f
      ceil_cost = cost.to_i
      cost - ceil_cost > 0 ? cost : ceil_cost
    end
  end
end
