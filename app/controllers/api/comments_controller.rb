class Api::CommentsController < Api::BaseController
  before_action :load_post!, only: [:index, :create]
  before_action :load_comment!, only: [:show, :update, :destroy, :make_visible, :hide, :show_all_by_user, :hide_all_by_user]

  protect(:index, :create, :show) { can? :comment, post }
  protect(:update, :destroy, :make_visible, :hide, :show_all_by_user, :hide_all_by_user) { can? :manage, @comment }

  def index
    query = Queries::Comments.new(post: @post, performer: current_user, start_id: params[:last_comment_id], limit: 10)
    comments_data = query.results.map { |c| api_response.comment_data(c) }
    json_success comments: comments_data, has_more: query.has_more_comments?
  end

  def show
    json_success api_response.comment_data(@comment)
  end

  def create
    comment = CommentManager.new(user: current_user.object, post: @post).create(params.slice(:message, :mentions))
    json_success api_response.comment_data(comment)
  end

  def update
    CommentManager.new(user: current_user.object, comment: @comment).update(params.slice(:message, :mentions))
    json_success api_response.comment_data(@comment)
  end

  def destroy
    @comment.destroy
    EventsManager.comment_removed(user: current_user.object, comment: @comment)
    json_success api_response.comment_data(@comment)
  end

  def make_visible
    comment = CommentManager.new(user: current_user.object, comment: @comment).show
    json_success api_response.comment_data(comment)
  end

  def hide
    comment = CommentManager.new(user: current_user.object, comment: @comment).hide
    json_success api_response.comment_data(comment)
  end

  def show_all_by_user
    CommentManager.new(user: current_user.object, comment: @comment).show_all_by_user
    json_success api_response.comment_data(@comment)
  end

  def hide_all_by_user
    CommentManager.new(user: current_user.object, comment: @comment).hide_all_by_user
    json_success api_response.comment_data(@comment)
  end

  private

  def post
    @post || @comment.post
  end

  def load_post!
    @post = Post.where(id: params[:post_id]).first or error(404)
  end

  def load_comment!
    @comment = Comment.where(id: params[:id]).first or error(404)
  end
end
