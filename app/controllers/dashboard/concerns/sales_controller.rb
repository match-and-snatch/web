module Dashboard::Concerns::SalesController
  extend ActiveSupport::Concern

  ROLE = :sales

  included do
    include Concerns::DynamicContent
    protect { current_user.sales? }
    dynamic_template '/dashboard/sales/layouts/dashboard'
  end
end
