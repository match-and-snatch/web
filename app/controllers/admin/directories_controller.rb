class Admin::DirectoriesController < Admin::BaseController

  def show
    @users = Queries::Users.new(user: current_user, include_hidden: true).grouped_by_first_letter
    @user_ids_with_posts = User.joins(:posts).group("users.id").having("COUNT(posts.id) > 0").where(users: {id: @users.values.flatten.map(&:id)}).pluck(:id)
    json_render
  end
end

