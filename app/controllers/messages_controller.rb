class MessagesController < ApplicationController
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

  protected

  # @overload
  def process_http_code_error(error)
    case error.code
    when 401
      @owner = @target_user
      template = current_user.authorized? ? '/subscriptions/new' : '/subscriptions/new_unauthorized'
      json_popup popup: render_to_string(template: template, layout: false)
    else
      super
    end
  end

  private

  def load_target_user!
    @target_user = User.where(id: params[:user_id]).first or error(404)
  end
end

