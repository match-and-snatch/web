class SubscriptionsController < ApplicationController
  before_filter :authenticate!
  before_filter :load_user!

  def create
    SubscriptionManager.new(current_user.object).subscribe_to(@user)
    json_reload
  end

  private

  def load_user!
    @user = User.where(slug: params[:user_id]).first or error(404)
  end
end