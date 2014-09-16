module Concerns::CommentEventsTracker
  # @param user [User]
  # @param comment [Comment]
  def comment_created(user: , comment: )
    Event.create! user: user, action: 'comment_created', data: { message: comment.message }
  end

  # @param user [User]
  # @param comment [Comment]
  def comment_updated(user: , comment: )
    Event.create! user: user, action: 'comment_updated', data: { message: comment.message }
  end

  # @param user [User]
  # @param comment [Comment]
  def comment_mark_as_visible(user: , comment: )
    Event.where(user_id: user.id, action: 'comment_mark_as_hidden', data: { comment_id: comment.id }.to_yaml).daily.delete_all
  end

  # @param user [User]
  # @param comment [Comment]
  def comment_mark_as_hidden(user: , comment: )
    Event.create! user: user, action: 'comment_mark_as_hidden', data: { comment_id: comment.id }
  end

  # @param user [User]
  # @param comment [Comment]
  def comment_removed(user: , comment: )
    Event.create! user: user, action: 'comment_removed', data: { comment_id: comment.id }
  end
end