class CommentLogger < BaseLogger
  log :comment_created, :comment_updated, :comment_shown, :comment_hidden, :comment_removed do |event|
    if subject
      event.data = { comment_id:   subject.id,
                     message:      subject.message,
                     post_id:      subject.post_id,
                     post_user_id: subject.post_user_id }
    end
  end
end
