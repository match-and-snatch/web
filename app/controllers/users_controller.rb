class UsersController < ApplicationController
  before_filter :load_user!, only: %i(edit sample_profile update profile update_payment_information)
  layout 'finish_profile'

  # Registers new user
  def create
    user = AuthenticationManager.new(email:                 params[:email],
                                     first_name:            params[:first_name],
                                     last_name:             params[:last_name],
                                     password:              params[:password],
                                     password_confirmation: params[:password_confirmation]).register
    session_manager.login(user.email, params[:password])

    render json: {status: 'redirect', url: finish_profile_path}
  rescue ManagerError => e
    render json: {status: 'failed', errors: e.messages}
  end

  def edit
    respond_to do |format|
      format.html
      format.json do
        render json: {status: 'success', html: render_to_string(action: 'edit_price_slug', layout: false, formats: [:html])}
      end
    end
  end

  def sample_profile
    render json: {status: 'success', html: render_to_string(action: 'sample_profile', layout: false, formats: [:html])}
  end

  def update
    UserProfileManager.new(@user).update(subscription_cost: params[:subscription_cost], slug: params[:slug])
    render json: {status: 'replace', html: render_to_string(action: 'edit_payment_information', layout: false, formats: [:html])}
  rescue ManagerError => e
    render json: {status: 'failed', errors: e.messages}
  end

  def update_payment_information
    UserProfileManager.new(@user).update_payment_information holder_name:    params[:holder_name],
                                                             routing_number: params[:routing_number],
                                                             account_number: params[:account_number]
    render json: {status: 'redirect', url: profile_path}
  rescue ManagerError => e
    render json: {status: 'failed', errors: e.messages}
  end

  def profile
    render json: @user.inspect
  end

  private

  def load_user!
    @user = current_user.object
  end
end