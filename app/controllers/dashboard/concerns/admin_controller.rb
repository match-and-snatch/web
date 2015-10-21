module Dashboard::Concerns::AdminController
  extend ActiveSupport::Concern

  ROLE = :admin

  included do
    include Concerns::DynamicContent
    protect { current_user.admin? }
    dynamic_template '/dashboard/admin/layouts/dashboard'
  end
end
