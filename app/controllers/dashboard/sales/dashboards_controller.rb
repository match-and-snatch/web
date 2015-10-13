class Dashboard::Sales::DashboardsController < Dashboard::Sales::BaseController

  def show
    @overview = OverviewPresenter.new
    json_render
  end
end