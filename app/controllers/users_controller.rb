class UsersController < ApplicationController
  layout 'finish_profile'

  before_filter :load_user!, except: :create
  #before_filter :redirect_complete, only: :edit

  # Registers new user
  def create
    user = AuthenticationManager.new(email:                 params[:email],
                                     first_name:            params[:first_name],
                                     last_name:             params[:last_name],
                                     password:              params[:password],
                                     password_confirmation: params[:password_confirmation]).register
    session_manager.login(user.email, params[:password])

    json_redirect finish_profile_path
  end

  def edit
    respond_to do |format|
      format.html
      format.json { json_render 'edit_price_slug' }
    end
  end

  def update
    UserProfileManager.new(@user).update(subscription_cost: params[:subscription_cost], slug: params[:slug])
    json_replace 'edit_payment_information'
  end

  def update_payment_information
    UserProfileManager.new(@user).update_payment_information holder_name:    params[:holder_name],
                                                             routing_number: params[:routing_number],
                                                             account_number: params[:account_number]
    json_redirect account_info_path
  end

  def account_info
    render json: @user.inspect
  end

  private

  def redirect_complete
    redirect_to account_info_path if @user.complete_profile?
  end

  def load_user!
    @user = current_user.object
  end
end