class Api::UsersController < Api::BaseController
  before_action :load_user!, only: :show

  def show
    json_susccess(
      access: {
        owner: current_user == @user,
        subscribed: current_user.subscribed_to?(@user)
      },
      name: @user.name,
      slug: @user.slug,
      types: @user.profile_types.map(&:title),
      subscription_cost: @user.subscription_cost,
      cost: @user.cost,
      profile_picture_url: @user.profile_picture_url,
      cover_picture_url: @user.cover_picture_url,
      cover_picture_position: @user.cover_picture_position
    )
  end

  private

  def load_user!
    @user = User.where(slug: params[:id]).first or error(404)
  end
end