class Dashboard::Admin::ProfileOwnersController < Dashboard::ProfileOwnersController
  protect { current_user.admin? }
end
