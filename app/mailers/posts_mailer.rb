class PostsMailer < ApplicationMailer
  subscribe :comment_created do
    recipients { payload.subject.mentioned_users }

    subject do
      if recipient.id == payload.subject.post_user_id
        'You were mentioned on your profile page'
      else
        "You were mentioned on #{payload.subject.post_user.try(:name)} profile page."
      end
    end

    email :mentioned do
      @comment = payload.subject
      @mentioned_user = recipient
      @post = @comment.post
      @mentioner = @comment.user
      @post_user= @post.user
    end
  end

  def created(post, user)
    @user = user
    @post = post
    mail to: @user.email, subject: "New post by #{post.user.name}!"
  end
end
