class ContributionsController < ApplicationController
  before_filter :authenticate!
  before_filter :load_contribution!, only: [:cancel, :destroy]

  protect(:destroy) { can? :delete, @contribution }

  def new
    json_popup
  end

  def create
    target_user = User.find_by_id(params[:target_user_id]) or error(400)
    amount = params[:amount].presence || (params[:custom_amount].to_i * 100)
    manager.create(target_user: target_user, amount: amount, recurring: params[:recurring])
    json_reload(notice: 'Thanks for you contribution!')
  end

  def cancel
    json_popup
  end

  def destroy
    manager.delete
    notice(:contribution_cancelled, profile_name: @contribution.target_user.profile_name)
    json_reload
  end

  private

  def load_contribution!
    @contribution = Contribution.where(id: params[:id]).first or error(404)
  end

  def manager
    ContributionManager.new(user: current_user.object, contribution: @contribution)
  end
end


