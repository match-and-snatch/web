class Api::ContributorsController < Api::BaseController
  protect(:index) { current_user.authorized? }

  def index
    @contributions = Contribution.includes(:user, :parent).where(target_user_id: current_user.id).order('contributions.created_at DESC')
    if params[:year_month].present?
      year_month = YearMonth.to_date_from_string(params[:year_month])
      @contributions = @contributions.where(created_at: (year_month.beginning_of_month..year_month.end_of_month))
    end
    json_success contributors: @contributions.map {|contribution| api_response.contribution_data(contribution)}
  end
end

