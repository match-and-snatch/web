class Api::StatusPostsController < Api::PendingPostsController
  def new
    json_success pending_post_data.merge({ post_type: 'StatusPost' })
  end
end
