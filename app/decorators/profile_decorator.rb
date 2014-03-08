class ProfileDecorator < BaseDecorator
  delegate :full_name, to: :object

  # @param user [User]
  def initialize(user)
    raise ArgumentError unless user.is_a? User
    @object = user
  end

  def recent_posts
    @object.posts.order('created_at DESC').limit(10)
  end

  # @return [Integer, Float]
  def subscription_cost
    cost = object.subscription_cost
    ceil_cost = cost.to_i
    cost - ceil_cost > 0 ? cost : ceil_cost
  end
end
