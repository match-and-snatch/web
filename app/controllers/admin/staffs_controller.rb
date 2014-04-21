class Admin::StaffsController < Admin::BaseController
  def index
    @users = User.admins.limit(200).to_a
    json_render
  end
end