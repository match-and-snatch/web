class CommentsController < ApplicationController
  include Concerns::PublicProfileHandler

  before_action :authenticate!, except: [:show, :create]
  before_action :load_post!, only: [:index, :create]
  before_action :load_comment!, only: [:edit, :update, :destroy, :confirm_make_visible, :make_visible, :confirm_hide, :hide, :show_all_by_user, :hide_all_by_user, :like, :show]

  protect(:index, :create, :like, :show, :text) { can? :comment, post }
  protect(:edit, :update, :confirm_make_visible, :make_visible, :confirm_hide, :hide, :show_all_by_user, :hide_all_by_user, :destroy) { can? :manage, @comment }

  def index
    @query = Queries::Comments.new(post: @post, performer: current_user, start_id: params[:last_comment_id])
    json_replace
  end

  def show
    json_replace partial: 'comment_row', locals: { comment: @comment }
  end

  def create
    @comment = CommentManager.new(user: current_user.object, post: @post).create(params.slice(:message, :mentions))
    json_render
  end

  def edit
    json_replace
  end

  def update
    CommentManager.new(user: current_user.object, comment: @comment).update(params.slice(:message, :mentions))
    render_comment_row
  end

  def text
    @truncate = params.bool(:truncate)
    json_replace
  end

  def confirm_make_visible
    json_popup
  end

  def make_visible
    CommentManager.new(user: current_user.object, comment: @comment).show
    render_comment_row
  end

  def confirm_hide
    json_popup
  end

  def hide
    CommentManager.new(user: current_user.object, comment: @comment).hide
    render_comment_row
  end

  def show_all_by_user
    CommentManager.new(user: current_user.object, comment: @comment).show_all_by_user
    json_success visible: true
  end

  def hide_all_by_user
    CommentManager.new(user: current_user.object, comment: @comment).hide_all_by_user
    json_success visible: false
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
