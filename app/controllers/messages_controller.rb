class MessagesController < ApplicationController
  include Concerns::PublicProfileHandler

  before_filter :load_target_user!

  protect { can? :send_message_to, @target_user }

  def new
    json_popup
  end

  def create
    MessagesManager.new(user: current_user.object).create(target_user: @target_user,
                                                          message: params[:message])
    json_success notice: :new_message
  end

  private

  def load_target_user!
    @target_user = User.where(id: params[:user_id]).first or error(404)
  end
end

