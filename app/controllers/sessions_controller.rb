class SessionsController < ApplicationController

  rescue_from ManagerError do
    json_fail message: t('errors.invalid_login')
  end

  # Shows user login form
  def new
    session_manager.logout
  end

  # Logins user
  def create
    session_manager.login(params[:email], params[:password])
    json_redirect account_info_path
  end

  # Logs user out
  def logout
    session_manager.logout
    redirect_to root_path
  end
end