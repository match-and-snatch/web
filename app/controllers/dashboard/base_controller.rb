class Dashboard::BaseController < ApplicationController
  include Concerns::DynamicContent

  protect { current_user.staff? }

  before_filter do
    current_user.current_role = self.class::ROLE
  end
end
