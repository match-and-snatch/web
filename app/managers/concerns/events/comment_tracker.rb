module Concerns::Events::CommentTracker
  # @param user [User]
  # @param comment [Comment]
  def comment_created(user: , comment: )
    Event.create! user: user,
                  action: 'comment_created',
                  data: data_hash(comment)
  end

  # @param user [User]
  # @param comment [Comment]
  def comment_updated(user: , comment: )
    Event.create! user: user,
                  action: 'comment_updated',
                  data: data_hash(comment)
  end

  # @param user [User]
  # @param comment [Comment]
  def comment_showed(user: , comment: )
    Event.where(user_id: user.id, action: 'comment_hidden', data: data_hash(comment).to_yaml).daily.delete_all
  end

  # @param user [User]
  # @param comment [Comment]
  def comment_hidden(user: , comment: )
    Event.create! user: user, action: 'comment_hidden', data: data_hash(comment)
  end

  # @param user [User]
  # @param comment [Comment]
  def comment_removed(user: , comment: )
    Event.create! user: user,
                  action: 'comment_removed',
                  data: data_hash(comment)
  end

  private

  def data_hash(comment)
    { message:      comment.message,
      post_id:      comment.post_id,
      post_user_id: comment.post_user_id }
  end
end