class CurrentUserDecorator < UserDecorator
  delegate :pending_post_uploads, :admin?, :email, :billing_failed?, to: :object

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
    when Dialogue
      subject.user == object || subject.target_user == object
    when User
      case action
      when :login_as             then object.admin?
      when :subscribe_to         then subject.id != object.id && authorized? && !subscribed_to?(subject) && !billing_failed?
      when :see_subscribe_button then subject.id != object.id &&                !subscribed_to?(subject) && !billing_failed?
      when :see                  then subject.id == object.id ||                 subscribed_to?(subject) || subject.has_public_profile?
      when :manage               then subject.id == object.id
      when :send_message_to      then subscribed_to?(subject) && !billing_failed?
      else
        raise ArgumentError, "No such action #{action}"
      end
    when Upload
      case action
      when :manage then subject.user_id == object.id
      end
      when Comment
      case action
      when :delete, :manage then subject.user_id == object.id || subject.post_user_id == object.id
      else
        raise ArgumentError, "No such action #{action}"
      end
    when Post
      case action
      when :see            then object.id == subject.user_id || subscribed_to?(subject.user)
      when :delete         then object.id == subject.user_id
      when :like, :comment then object.id == subject.user_id || subscribed_to?(subject.user)
      else
        raise ArgumentError, "No such action #{action}"
      end
    when Subscription
      case action
      when :delete then object.id == subject.user_id
      else
        raise ArgumentError, "No such action #{action}"
      end
    else
      raise ArgumentError, "No such subject #{subject.inspect}"
    end
  end

  # @return [Array]
  def latest_subscriptions
    object.subscriptions.
      includes(:target_user).
      order('created_at DESC').
      where(["subscriptions.removed = 'f' OR (subscriptions.removed = 't' AND subscriptions.charged_at > ?)", 1.month.ago]).
      limit(10).map do |subscription|
      [subscription, ProfileDecorator.new(subscription.target_user)]
    end
  end

  def has_posts?
    object.posts.any?
  end

  def likes?(post)
    object.likes.where(post_id: post.id).any?
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
end
