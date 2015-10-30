class Dashboard::Sales::UsersController < Dashboard::UsersController
  include Dashboard::Concerns::SalesController

  before_action :load_user!, only: [:login_as]
end
