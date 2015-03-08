class Api::UsersController < Api::BaseController
  before_action :load_user!, only: [:show, :update_name, :update_profile_picture]

  def search
    users = Queries::Users.new(user: current_user, query: params[:q]).profile_owners_by_text
    json_success(users.map(&method(:user_data)))
  end

  def show
    respond_with_user_data
  end

  def update_name
    manager.update_profile_name(params[:name])
    respond_with_user_data
  end

  def update_profile_picture
    manager.update_profile_picture(params[:transloadit])
    respond_with_user_data
  end

  private

  def manager
    @manager ||= UserProfileManager.new(@user)
  end

  def load_user!
    @user = User.where(slug: params[:id]).first or error(404)
  end

  def respond_with_user_data
    json_success(user_data(@user.reload))
  end

  def user_data(user)
    {
      access: {
        owner: current_user == user,
        subscribed: current_user.subscribed_to?(user)
      },
      name: user.name,
      slug: user.slug,
      types: user.profile_types.map(&:title),
      subscription_cost: user.subscription_cost,
      cost: user.cost,
      profile_picture_url: user.profile_picture_url,
      cover_picture_url: user.cover_picture_url,
      cover_picture_position: user.cover_picture_position
    }
  end
end