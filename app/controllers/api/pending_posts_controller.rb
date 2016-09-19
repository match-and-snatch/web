class Api::PendingPostsController < Api::BaseController
  before_action :init_profile, only: [:new, :cancel]

  protect(:new, :create, :update, :cancel) { current_user.authorized? } # TODO (DJ): FIX ME

  def create
    post = create_post
    json_success api_response.post_data(post)
  end

  def update
    PostManager.new(user: current_user.object).update_pending(params.slice(%i[message title keywords]))
    json_success
  end

  private

  def pending_post_data
    {
      id: @profile.pending_post.id,
      title: @profile.pending_post.title,
      message: @profile.pending_post.message,
      keywords: @profile.pending_post.keywords
    }
  end

  def init_profile
    @profile = ProfileDecorator.new(current_user.object)
  end

  def manager
    @manager ||= PostManager.new(user: current_user.object)
  end
end
