class UsersController < ApplicationController
  before :show, :load_user!

  # Shows registration form
  def new
  end

  # Registers new user
  def create
    login AuthenticationManager.new(params[:email], params[:password]).register
    redirect_to profile_path
  rescue ManagerError => e
    render text: e.message
  end

  def profile
    render current_user.inspect
  end

  def show
    render @user.inspect
  end

  private

  def load_user!
    # ...
  end
end