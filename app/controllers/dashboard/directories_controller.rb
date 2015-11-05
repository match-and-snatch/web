class Dashboard::DirectoriesController < Dashboard::BaseController

  before_action :prepare_letter!, only: :show

  def index
    json_render
  end

  def show
    @users = Queries::Users.new(user: current_user, include_hidden: true, query: @letter).by_first_letter.page(params[:page]).per(100)
    @user_ids_with_posts = User.joins(:posts).group("users.id").having("COUNT(posts.id) > 0").where(users: {id: @users}).pluck(:id)
    json_render
  end

  private

  def prepare_letter!
    @letter = params[:id]
  end
end

