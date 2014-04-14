class CurrentUserDecorator < UserDecorator
  delegate :pending_post_uploads, :admin?, :email, to: :object

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
    return true if object.admin?

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
    when Upload
    case action
    when :manage then subject.user_id == object.id
    end
    when Comment
    case action
    when :delete then subject.user_id == object.id || subject.post_user_id == object.id
    else
      raise ArgumentError, "No such action #{action}"
    end
    when Post
    case action
    when :see then object.id == subject.user.id || subscribed_to?(subject.user)
    else
      raise ArgumentError, "No such action #{action}"
    end
    else
      raise ArgumentError, "No such subject #{subject.inspect}"
    end
  end

  def idols
    User.joins(source_subscriptions: :target_user).
      where(subscriptions: {user_id: object.id}).
      order('subscriptions.created_at DESC').
      limit(10)
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

  def pending_photos
    @pending_photos ||= object.pending_post_uploads.photos.to_a
  end

  def pending_videos
    @pending_videos ||= object.pending_post_uploads.videos.to_a
  end
end
