class Api::StatusPostsController < Api::PendingPostsController
  def new
    json_success pending_post_data.merge({ post_type: 'StatusPost' })
  end

  protected

  def create_post
    manager.create_status_post params.slice(:keyword_text, :message).merge(notify: params.bool(:notify))
  end
end
