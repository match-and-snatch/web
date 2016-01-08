class CurrentUserDecorator < UserDecorator
  delegate :pending_post_uploads, :roles, :admin?, :sales?, :staff?, :email, :billing_failed?, :cc_declined?, :partner_fees, :locked?, :cost_approved?, to: :object
  attr_accessor :current_role

  # @param user [User, nil]
  def initialize(user = nil)
    @object = user || User.new
  end

  # Returns dialogues with active subscribers / profile owners
  # @param page [Integer, String]
  # @param per_page [Integer]
  # @return [Array<Dialogue>]
  def accessible_dialogues(page: 1, per_page: 15)
    dialogues(page: page, per_page: per_page).to_a.tap do |result|
      result.select! do |dialogue|
        if dialogue.recent_message
          user = dialogue.recent_message.user
          target_user = dialogue.recent_message.target_user
          user.subscribed_to?(target_user) || target_user.subscribed_to?(user)
        end
      end
    end
  end

  # Returns all dialogues
  # @param page [Integer, String]
  # @param per_page [Integer]
  # @return [ActiveRecord::Relation]
  def dialogues(page: 1, per_page: 15)
    @dialogues ||= object.dialogues
      .not_removed
      .includes(recent_message: [:user, :target_user])
      .order(recent_message_at: :desc)
      .page(page).per(per_page)
  end

  # @return [Symbol]
  def lock_type
    if object.lock_type.present?
      object.lock_type.to_sym
    end
  end

  def authorized?
    !object.new_record?
  end

  def banned?
    object.locked? || object.cc_declined?
  end

  # @param action [Symbol]
  # @param subject
  # @raise [ArgumentError] if action or subject are not registered
  # @return [true, false]
  def can?(action, subject)
    Ability.new(object).can?(action, subject)
  end

  # @return [Array]
  def recent_subscriptions_options
    recent_subscriptions.map { |s| [s.target_user.name, s.target_user_id] }
  end

  # @return [ActiveRecord::Relation]
  def recent_subscriptions
    object.subscriptions.accessible.includes(:target_user).order(created_at: :desc)
  end

  # @return [Array]
  def latest_subscriptions
    recent_subscriptions.limit(10).map do |subscription|
      [subscription, ProfileDecorator.new(subscription.target_user)]
    end
  end

  def has_posts?
    object.posts.any?
  end

  # @param likable [Post, Comment]
  def likes?(likable)
    case likable
    when Post
      object.likes.where(post_id: likable.id).any?
    when Comment
      object.likes.where(comment_id: likable.id).any?
    else
      raise ArgumentError
    end
  end

  def has_subscriptions?
    object.subscriptions.any?
  end

  def ==(other)
    case other
    when User
      other.id == object.id
    when UserDecorator
      other.object.id == object.id
    else
      super
    end
  end

  def pending_audios
    @pending_audios ||= AudioPost.pending_uploads_for(object).to_a
  end

  def pending_documents
    @pending_documents ||= DocumentPost.pending_uploads_for(object).to_a
  end

  def pending_photos
    @pending_photos ||= PhotoPost.pending_uploads_for(object).to_a
  end

  def pending_videos
    @pending_videos ||= VideoPost.pending_uploads_for(object).to_a
  end

  def pending_video
    @pending_video ||= pending_videos.first
  end

  def pending_video_previews
    @pending_video_previews ||= object.pending_video_preview_photos.to_a
  end
end
