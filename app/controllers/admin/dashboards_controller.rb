class Admin::DashboardsController < Admin::BaseController

  def show
    @overview = OverviewPresenter.new
    json_render
  end
end