class PendingPostsController < ApplicationController
  before_filter :authenticate!
  before_filter :init_profile, only: :new

  def new
    json_replace
  end

  def create
    had_posts = current_user.has_posts?
    @post = create_post
    had_posts ? json_prepend : json_replace
  end

  def update
    PostManager.new(user: current_user.object).update_pending message:  params[:message],
                                                              title:    params[:title],
                                                              keywords: params[:keywords]
    json_success
  end

  protected

  def create_post
    raise NotImplementedError
  end

  private

  def init_profile
    @profile = ProfileDecorator.new(current_user.object)
  end
end