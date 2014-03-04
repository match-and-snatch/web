class PostsController < ApplicationController
  before_filter :authenticate!

  def create
    @post = PostManager.new(user: current_user.object).create(params[:message])
    json_render
  end
end
