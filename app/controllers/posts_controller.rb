class PostsController < ApplicationController
  before_filter :authenticate!

  def create
    @post = PostManager.new(current_user.object).create(params[:message])
    json_render
  end
end
