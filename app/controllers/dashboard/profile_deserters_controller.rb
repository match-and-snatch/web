class Dashboard::ProfileDesertersController < Dashboard::BaseController
  def index
    query = User.where(is_profile_owner: false)
              .joins(:source_subscriptions, :events)
              .where(events: {action: 'profile_page_removed'})
              .select('users.*, MAX(events.created_at) AS profile_page_removed_at')
              .group('users.id')

    if params[:sort_by]
      query = query.order("#{params[:sort_by]} #{params[:sort_direction]}")
    else
      query = query.order('profile_page_removed_at DESC')
    end

    @users = ProfileDecorator.decorate_collection(query.page(params[:page]).per(100))

    json_render
  end
end
