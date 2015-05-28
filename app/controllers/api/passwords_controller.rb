class Api::PasswordsController < Api::BaseController
  skip_before_action :authenticate_by_api_token

  before_action :load_user!, only: [:edit, :update]

  def restore
    reset_session
    AuthenticationManager.new(email: params[:email]).restore_password
    notice(:password_sent, email: params[:email])
    json_success
  end

  def edit
    json_success
  end

  def update
    manager = AuthenticationManager.new email: @user.email,
                                        password: params[:password],
                                        password_confirmation: params[:password_confirmation]
    manager.change_password
    notice :password_set
    json_success
  end

  private

  def load_user!
    @user = User.where(password_reset_token: params[:token]).first
    unless @user
      notice :invalid_email_token
      error(404)
    end
  end
end