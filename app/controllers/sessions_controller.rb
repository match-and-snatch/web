class SessionsController < ApplicationController

  # Registers users
  def create
    login AuthenticationManager.new(params[:email], params[:password]).authenticate
    redirect_to profile_path
  rescue ManagerError => e
    render text: e.message
  end

  # Shows user login form
  def new
  end

  # Logs user out
  def logout
    leave_session
  end
end