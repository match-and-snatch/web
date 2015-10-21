class Users::DirectoriesController < ApplicationController
  include Concerns::DynamicContent

  before_action :prepare_letter!

  def show
    @users = Queries::Users.new(user: current_user, query: @letter).by_first_letter
    json_render
  end

  private

  def prepare_letter!
    @letter = params[:id]
  end
end
