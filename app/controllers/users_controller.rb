class UsersController < ApplicationController
  before :show, :load_user!

  # Shows registration form
  def new
  end

  # Registers new user
  def create
    user = AuthenticationManager.new(params[:email], params[:password]).register(params[:login])
    session_manager.login(user.email, params[:password])

    redirect_to profile_path
  rescue ManagerError => e
    render text: e.message
  end

  def profile
    render text: current_user.object.attributes.inspect
  end

  def show
    render @user.inspect
  end

  private

  def load_user!
    @user = UserDecorator.decorate(User.where(slug: params[:id]).first) or error(404)
  end
end