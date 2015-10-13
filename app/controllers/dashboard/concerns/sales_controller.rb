module Dashboard::Concerns::SalesController
  extend ActiveSupport::Concern

  ROLE = :sales
  DASHBOARD_TEMPLATE = '/dashboard/sales/layouts/dashboard'.freeze

  included do
    protect { current_user.sales? }
  end
end
