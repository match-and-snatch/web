class SessionsController < ApplicationController

  # Shows user login form
  def new
    session_manager.logout
  end

  # Logins user
  def create
    session_manager.login(params[:email], params[:password])
    json_redirect account_info_path
  rescue ManagerError
    json_fail message: t(:invalid_login, scope: :errors)
  end

  # Logs user out
  def logout
    session_manager.logout
    redirect_to root_path
  end
end