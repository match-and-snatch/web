class ProfileDecorator < UserDecorator
  delegate :transfer, :custom_profile_page_css, :payments_count,
           :payments_amount, :unsubscribers_count, to: :object

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
  def contacts_info_links
    @contacts_info ||= Hash.new do |hash, key|
      hash[key] = object.contacts_info[key].presence || 'javascript: void(0)'
    end
  end

  # @return [String]
  def class_for(whatever)
    'pending' if object.contacts_info[whatever].blank?
  end

  # @return [Integer, Float]
  def subscription_cost
    @subscription_cost ||= begin
      cost = object.subscription_cost
      ceil_cost = cost
      cost - ceil_cost > 0 ? cost : ceil_cost
    end
  end

  # @return [PendingPost]
  def pending_post
    @pending_post ||= object.pending_post || PendingPost.new
  end

  def pending_payments_count
    object.pending_subs_count || 0
  end

  def plain_profile_types
    object.profile_types.map(&:title).join(' / ').html_safe
  end

  def created_at
    object.created_at.to_date.to_s(:full)
  end

  def has_welcome_media?
    welcome_video.present? || welcome_audio.present?
  end

  def estimated_payout
    @estimated_payout ||= object.cost * object.subscribers_count
  end
end
