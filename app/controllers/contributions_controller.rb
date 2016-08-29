class ContributionsController < ApplicationController
  include Concerns::PublicProfileHandler

  before_action :authenticate!, except: [:new, :create]
  before_action :load_contribution!, only: [:cancel, :destroy]
  before_action :load_target_user, only: [:new]
  before_action :load_target_user!, except: [:index, :new, :cancel, :destroy]

  protect(:create) { can? :make, Contribution.new(target_user: @target_user) }
  protect(:destroy) { can? :delete, @contribution }

  def index
    @contributions = ContributionsPresenter.new(user: current_user.object, year: params[:year])
    params[:year] ? json_replace : json_render
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

    manager.create({target_user: @target_user, amount: amount, recurring: params.bool(:recurring), message: params[:message]})
    json_reload(notice: 'Thanks for your contribution!')
  rescue ManagerError => e
    e.on?(:amount) ? raise : json_reload
  end

  def cancel
    json_popup
  end

  def destroy
    manager.cancel
    notice(:contribution_cancelled, profile_name: @contribution.target_user.profile_name)
    json_reload
  end

  private

  def load_public_user!
    @target_user = current_user
  end

  def load_target_user
    @target_user = User.find_by_id(params[:target_user_id]) if params[:target_user_id]
  end

  def load_target_user!
    load_target_user or error(400)
  end

  def load_contribution!
    @contribution = Contribution.where(id: params[:id]).first or error(404)
  end

  def manager
    ContributionManager.new(user: current_user.object, contribution: @contribution)
  end
end
