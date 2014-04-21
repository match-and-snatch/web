class LikesController < ApplicationController
  before_filter :authenticate!
  before_filter :load_post!

  def create
    LikesManager.new(current_user.object).toggle(@post)
    json_success html: render_to_string(partial: 'like', locals: {post: @post})
  end

  private

  def load_post!
    @post = Post.where(id: params[:post_id]).first or error(404)
  end
end