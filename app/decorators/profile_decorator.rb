class ProfileDecorator < BaseDecorator
  delegate :full_name, :profile_picture_url, :original_profile_picture_url, :cover_picture_url, :original_cover_picture_url, :slug, to: :object

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

  def recent_posts
    @object.posts.order('created_at DESC, id DESC').limit(5)
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
