class Api::CommentsController < Api::BaseController
  before_action :load_post!, only: [:index, :create]
  before_action :load_comment!, only: [:destroy]

  protect(:index, :create) { can? :comment, post }
  protect(:destroy) { can? :manage, @comment }

  def index
    query = Queries::Comments.new(post: @post, start_id: params[:last_comment_id], limit: 9999)
    comments_data = query.results.map { |c| comment_data(c) }
    json_success comments_data
  end

  def create
    comment = CommentManager.new(user: current_user.object, post: @post).create(params.slice(:message, :mentions))
    json_success comment_data(comment)
  end

  def destroy
    @comment.destroy
    EventsManager.comment_removed(user: current_user.object, comment: @comment)
    json_success
  end

  private

  def comment_data(comment)
    {
      id: comment.id,
      message: comment.message,
      created_at: comment.created_at,
      user: {
        slug: comment.user.slug,
        name: comment.user.name,
        picture_url: comment.user.comment_picture_url,
        has_profile: comment.user.has_profile_page?
      },
      replies: comment.replies.map { |r| comment_data(r) },
      likes: comment.likers_data.merge(liked: current_user.likes?(comment))
    }
  end

  def post
    @post || comment.post
  end

  def load_post!
    @post = Post.where(id: params[:post_id]).first or error(404)
  end

  def load_comment!
    @comment = Comment.where(id: params[:id]).first or error(404)
  end
end
