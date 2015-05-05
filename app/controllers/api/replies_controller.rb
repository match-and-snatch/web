class Api::RepliesController < Api::BaseController
  before_action :load_comment!, only: [:create]
  before_action :load_reply!, only: [:update, :make_visible, :hide]

  protect(:create) { can? :comment, @comment.post }
  protect(:update, :make_visible, :hide) { can? :manage, @reply }

  def create
    reply = CommentManager.new(user: current_user.object, post: @comment.post, parent: @comment).create(params.slice(:message, :mentions))
    json_success reply_data(reply)
  end

  def update
    @reply.update_attributes(message: params[:message])
    json_success reply_data(@reply)
  end

  def make_visible
    reply = CommentManager.new(user: current_user.object, comment: @reply).show
    json_success reply_data(reply)
  end

  def hide
    reply = CommentManager.new(user: current_user.object, comment: @reply).hide
    json_success reply_data(reply)
  end

  private

  def reply_data(reply)
    {
      id: reply.id,
      message: reply.message,
      created_at: reply.created_at,
      hidden: reply.hidden,
      mentions: reply.mentions,
      access: {
        owner: current_user == reply.user,
        post_owner: current_user == reply.post_user
      },
      user: {
        slug: reply.user.slug,
        name: reply.user.name,
        picture_url: reply.user.comment_picture_url,
        has_profile: reply.user.has_profile_page?
      },
      likes: reply.likers_data.merge(liked: current_user.likes?(reply))
    }
  end

  def load_reply!
    @reply = Comment.where(id: params[:id]).first or error(404)
  end

  def load_comment!
    @comment = Comment.where(id: params[:comment_id]).first or error(404)
  end
end
