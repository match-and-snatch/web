class CommentFlow < BaseFlow
  protect :create, :update, :hide, :show, :remove, :toggle_like

  factory do
    attr(:parent)
    attr(:post).required.default_to -> { parent.try(:post) }
    attr(:message).required
    attr(:mentions)
    attr(:user).map_to(performer)
    attr(:post_user_id).map_to -> { post.user_id }

    after do
      notify :comment_created, comment
    end
  end

  update do
    attr(:message).required

    after do
      notify :comment_updated, comment
    end
  end

  action :show do
    comment.hidden = false
    save
    notify :comment_shown, comment
  end

  action :hide do
    comment.hidden = true
    save
    notify :comment_hidden, comment
  end

  action :remove do
    comment.destroy
    notify :comment_removed, comment
  end

  action :toggle_like do
    like = performer.likes.find_or_initialize_by(comment_id: comment.id)
    flows.like(like).toggle
  end

  flow :like do
    factory do
      attr(:comment).required.default_to -> { like.try(:comment) }
      attr(:likable).map_to -> { comment }
      attr(:target_user).map_to -> { comment.user }
      attr(:user).map_to(performer)

      after { notify :like_created, like }
    end

    action :toggle do
      like.persisted? ? unlike : create
    end

    action :unlike do
      like.destroy
      notify :like_removed, like
    end
  end
end