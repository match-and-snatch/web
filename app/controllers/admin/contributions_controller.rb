class Admin::ContributionsController < Admin::BaseController

  def index
    @contributions = Contribution.all
    json_render
  end
end
