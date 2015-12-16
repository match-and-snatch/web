class Dashboard::Admin::DuplicatesController < Dashboard::Admin::BaseController

  def index
    @duplicates = if params[:by_card]
                    CardsDuplicatesPresenter.new(page: params[:page])
                  else
                    UsersDuplicatesPresenter.new(page: params[:page])
                  end
    json_render
  end
end
