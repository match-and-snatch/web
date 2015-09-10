class Api::MessagesController < Api::BaseController
  include Concerns::PublicProfileHandler

  before_action :load_target_user!, only: [:create]

  protect(:search_recipients) { current_user.authorized? }

  def search_recipients
    users = Queries::Recipients.new(user: current_user.object, query: params[:q]).by_name
    json_success users.map {|user| api_response.user_data(user)}
  end

  def create
    @message = MessagesManager.new(user: current_user.object).create(target_user: @target_user, message: params[:message])
    json_success api_response.message_data(@message)
  end

  private

  def load_target_user!
    t = User.arel_table
    @target_user = User.where(id: params[:user_id]).first or error(404)
  end
end
