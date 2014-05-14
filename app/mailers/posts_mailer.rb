class PostsMailer < ApplicationMailer
  add_template_helper ApplicationHelper

  def created(post, user)
    @user = user
    @post = post
    mail to: @user.email, subject: "New post by #{post.user.name}!"
  end

  def mentioned(comment, mentioned_user)
    @comment        = comment
    @mentioned_user = mentioned_user
    @post           = @comment.post
    @mentioner      = @comment.user
    @post_user      = @post.user

    if @mentioned_user == @post_user
      subject = 'You were mentioned on your profile page'
    else
      subject = "You were mentioned on #{@post_user.name} profile page."
    end

    mail to: @mentioned_user.email, subject: subject
  end
end
