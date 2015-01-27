class CommentsController < ApplicationController
  include Concerns::PublicProfileHandler

  before_filter :authenticate!, except: [:show, :create]
  before_filter :load_post!, only: [:index, :create]
  before_filter :load_comment!, only: [:edit, :update, :destroy, :make_visible, :hide, :like, :show]

  protect(:index, :create, :like, :show) { can? :comment, post }
  protect(:edit, :update, :make_visible, :hide, :destroy) { can? :manage, @comment }

  def index
    @query = Queries::Comments.new(post: @post, start_id: params[:last_comment_id])
    json_replace
  end

  def show
    json_replace
  end

  def create
    @comment = CommentManager.new(user: current_user.object, post: @post).create(params.slice(:message, :mentions))
    json_render
  end

  def edit
    json_replace
  end

  def update
    @comment.update_attributes(message: params[:message])
    EventsManager.comment_updated(user: current_user.object, comment: @comment)
    render_comment_row
  end

  def make_visible
    CommentManager.new(user: current_user.object, comment: @comment).show
    render_comment_row
  end

  def hide
    CommentManager.new(user: current_user.object, comment: @comment).hide
    render_comment_row
  end

  def destroy
    @comment.destroy
    EventsManager.comment_removed(user: current_user.object, comment: @comment)
    json_replace
  end

  def like
    LikesManager.new(current_user.object).toggle(@comment)
    json_replace partial: 'like_small', locals: {comment: @comment}
  end

  protected

  # @overload
  def load_public_user!
    @target_user ||= @comment.try(:post_user) || @post.try(:user)
  end

  private

  def post
    @post || comment.post
  end

  def comment
    @comment || load_comment!
  end

  def load_comment!
    @comment = Comment.where(id: params[:id]).first or error(404)
  end

  def load_post!
    @post = Post.where(id: params[:post_id]).first or error(404)
  end

  def render_comment_row
    json_replace partial: 'comment_row', locals: {comment: @comment}
  end
end

