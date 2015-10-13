module Dashboard::Concerns::AdminController
  DASHBOARD_TEMPLATE = '/dashboard/admin/layouts/dashboard'.freeze
  extend ActiveSupport::Concern

  included do
    protect { current_user.admin? }
  end
end