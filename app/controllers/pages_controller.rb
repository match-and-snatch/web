class PagesController < ApplicationController
  skip_before_action :check_if_tos_accepted, only: [:terms_of_service, :privacy_policy, :faq, :pricing, :contact_us]

  def crossdomain
  end
end
