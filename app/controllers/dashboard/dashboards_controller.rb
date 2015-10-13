class Dashboard::DashboardsController < ApplicationController

  def show
    if current_user.roles.many?
      # Render links to available dashboards
    elsif current_user.roles.any?
      redirect_to [current_user.roles.first, :dashboard]
    else
      error(401)
    end
  end
end