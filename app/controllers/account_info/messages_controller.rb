class AccountInfo::MessagesController < AccountInfo::BaseController
  before_filter :load_target_user!

  def create
    @message = MessagesManager.new(user: current_user.object).
      create(target_user: @target_user, message: params[:message])
    json_append
  end

  private

  def load_target_user!
    @target_user = User.where(id: params[:user_id]).first or error(404)
  end
end
