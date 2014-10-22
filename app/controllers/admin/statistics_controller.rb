class Admin::StatisticsController < Admin::BaseController
  before_filter :initialize_statistic!

  def index
    json_render
  end

  def graphic
    json_replace
  end

  private

  def initialize_statistic!
    @statistic = StatisticPresenter.new(graph_type: params[:graph_type])
  end
end
