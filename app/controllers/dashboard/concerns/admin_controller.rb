module Dashboard::Concerns::AdminController
  extend ActiveSupport::Concern

  ROLE = :admin
  DASHBOARD_TEMPLATE = '/dashboard/admin/layouts/dashboard'.freeze

  included do
    protect { current_user.admin? }
  end
end