class MessagesController < ApplicationController
  before_filter :load_target_user!

  def new
    json_success popup: render_to_string('new', layout: false)
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
