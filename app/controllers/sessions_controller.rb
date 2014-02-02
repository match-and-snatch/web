class SessionsController < ApplicationController

  # Shows user login form
  def new
  end

  # Logins user
  def create
    session_manager.login(params[:email], params[:password])
    redirect_to profile_path
  rescue ManagerError => e
    render text: e.message
  end

  # Logs user out
  def logout
    session_manager.logout
    redirect_to root_path
  end
end