class Dashboard::Admin::DuplicatesController < Dashboard::Admin::BaseController

  def index
    @duplicates = UsersDuplicatesPresenter.new
    @card_duplicates = CardsDuplicatesPresenter.new
    json_render
  end
end
