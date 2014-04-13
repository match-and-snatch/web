class PendingPostsController < ApplicationController
  before_filter :authenticate!

  def update
    PostManager.new(user: current_user.object).update_pending message:  params[:message],
                                                              title:    params[:title],
                                                              keywords: params[:keywords]
    json_success
  end
end