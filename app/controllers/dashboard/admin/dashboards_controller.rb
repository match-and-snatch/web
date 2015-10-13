class Dashboard::Admin::DashboardsController < Dashboard::Admin::BaseController

  def show
    @overview = OverviewPresenter.new
    json_render
  end
end