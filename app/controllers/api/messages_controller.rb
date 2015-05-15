class Api::MessagesController < Api::BaseController
  include Concerns::PublicProfileHandler

  before_action :load_target_user!

  def create
    @message = MessagesManager.new(user: current_user.object).
        create(target_user: @target_user, message: params[:message])
    json_success message_data(@message)
  end

  private

  def load_target_user!
    t = User.arel_table
    @target_user = User.where(t[:id].eq(params[:user_id]).or(t[:slug].eq(params[:user_id]))).first or error(404)
  end

  def message_data(message)
    {
      id: message.id,
      created_at: message.created_at,
      message: message.message,
      contribution: message.contribution.present?,
      user: {
        name: message.user.name,
        picture_url: message.user.comment_picture_url
      }
    }
  end
end
