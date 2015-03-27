class Api::RepliesController < Api::BaseController
  before_action :load_comment!, only: [:create]

  protect(:create) { can? :comment, @comment.post }

  def create
    reply = CommentManager.new(user: current_user.object, post: @comment.post, parent: @comment).create(params.slice(:message, :mentions))
    json_success reply_data(reply)
  end

  private

  def reply_data(reply)
    {
        id: reply.id,
        message: reply.message,
        created_at: reply.created_at,
        user: {
            slug: reply.user.slug,
            name: reply.user.name,
            picture_url: reply.user.comment_picture_url,
            has_profile: reply.user.has_profile_page?
        },
        likes: reply.likers_data.merge(liked: current_user.likes?(reply))
    }
  end

  def load_comment!
    @comment = Comment.where(id: params[:comment_id]).first or error(404)
  end
end
