class ContributionsController < ApplicationController
  before_filter :authenticate!

  def new
    json_popup
  end

  def create
    target_user = User.find_by_id(params[:target_user_id]) or error(400)
    amount = params[:amount].presence || (params[:custom_amount].to_i * 100)
    ContributionManager.new(user: current_user.object).create(target_user: target_user, amount: amount, recurring: params[:recurring])
    json_reload(notice: 'Thanks for you contribution!')
  end
end


