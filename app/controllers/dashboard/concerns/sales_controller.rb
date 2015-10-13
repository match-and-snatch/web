module Dashboard::Concerns::SalesController
  DASHBOARD_TEMPLATE = '/dashboard/sales/layouts/dashboard'.freeze
  extend ActiveSupport::Concern

  included do
    protect { current_user.sales? }
  end
end
