class Dashboard::RecentProfilesController < Dashboard::BaseController
  def index
    query = User.profile_owners.where(has_complete_profile: true)

    case params[:filter]
      when 'with_posts'
        query = query.where.not(posts_count: 0)
      when 'without_posts'
        query = query.where(posts_count: 0)
    end

    @users = query.order(created_at: :desc).page(params[:page]).per(100)
    json_render
  end
end
