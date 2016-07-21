module Concerns::Events::CommentTracker
  # @param user [User]
  # @param comment [Comment]
  # @yield
  # @return [Event]
  def comment_created(user: , comment: , &block)
    create_event user: user,
                  subject: comment,
                  action: 'comment_created',
                  data: data_hash(comment),
                  &block
  end

  # @param user [User]
  # @param comment [Comment]
  # @yield
  # @return [Event]
  def comment_updated(user: , comment: , &block)
    create_event user: user,
                  subject: comment,
                  action: 'comment_updated',
                  data: data_hash(comment),
                  &block
  end

  # @param user [User]
  # @param comment [Comment]
  # @return [Integer]
  def comment_shown(user: , comment: )
    Event.where(user_id: user.id, action: 'comment_hidden').where(["events.data @> ?", data_hash(comment).to_json]).daily.delete_all
  end

  # @param user [User]
  # @param comment [Comment]
  # @yield
  # @return [Event]
  def comment_hidden(user: , comment: , &block)
    create_event user: user, subject: comment, action: 'comment_hidden', data: data_hash(comment), &block
  end

  # @param user [User]
  # @param comment [Comment]
  # @yield
  # @return [Event]
  def comment_removed(user: , comment: , &block)
    create_event user: user,
                  action: 'comment_removed',
                  data: data_hash(comment),
                  &block
  end

  private

  # @param comment [Comment]
  # @return [Hash]
  def data_hash(comment)
    { message:      comment.message,
      post_id:      comment.post_id,
      post_user_id: comment.post_user_id }
  end
end
