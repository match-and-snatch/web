class PasswordsController < ApplicationController
  before_filter :load_user!, only: [:edit, :update]

  def restore
    reset_session
    AuthenticationManager.new(email: params[:email]).restore_password
    notice(:password_sent, email: params[:email])
    json_reload
  end

  def edit
  end

  def update
    manager = AuthenticationManager.new email: @user.email,
                                        password: params[:password],
                                        password_confirmation: params[:password_confirmation]
    manager.change_password
    notice :password_set
    json_redirect root_path
  end

  private

  def load_user!
    @user = User.where(password_reset_token: params[:token]).first

    unless @user
      notice :invalid_email_token
      redirect_to root_path
    end
  end
end