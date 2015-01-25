class ContributionsController < ApplicationController
  include Concerns::PublicProfileHandler

  before_filter :authenticate!, except: [:new, :create]
  before_filter :load_contribution!, only: [:cancel, :destroy]
  before_filter :load_target_user!, except: [:index]

  protect(:create) { can? :make, Contribution.new }
  protect(:destroy) { can? :delete, @contribution }

  def index
    @contributions = Contribution.where(target_user_id: current_user.id)
    json_render
  end

  def new
    json_popup
  end

  def create

    if params[:amount].to_i.zero?
      amount = params[:custom_amount].to_i * 100
    else
      amount = params[:amount]
    end

    manager.create({target_user: target_user, amount: amount, recurring: params.bool(:recurring), message: params[:message]})
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

  def load_target_user!
    @target_user = User.find_by_id(params[:target_user_id]) or error(400)
  end

  def load_contribution!
    @contribution = Contribution.where(id: params[:id]).first or error(404)
  end

  def manager
    ContributionManager.new(user: current_user.object, contribution: @contribution)
  end
end


