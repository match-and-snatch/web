class Dashboard::Admin::DuplicatesController < Dashboard::Admin::BaseController
  before_action :load_user!, except: :index

  def index
    @duplicates = if params[:by_card]
                    CardsDuplicatesPresenter.new(page: params[:page])
                  else
                    UsersDuplicatesPresenter.new(page: params[:page])
                  end
    json_render
  end

  def confirm_mark_as_duplicate
    json_popup
  end

  def mark_as_duplicate
    UserManager.new(@user).set_invalid_email
    json_reload
  end

  private

  def load_user!
    @user = User.where(id: params[:id]).first or error(404)
  end
end
