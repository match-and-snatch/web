class Dashboard::BaseController < ApplicationController
  protect { current_user.staff? }

  before_filter do
    current_user.current_role = self.class::ROLE
  end

  protected

  # @param status [String]
  # @param json [Hash]
  # @option json [String, nil] :template
  def json_render_html(status, json = {})
    respond_to do |wants|
      wants.html do
        @content = json_body(json)
        render template: self.class::DASHBOARD_TEMPLATE
      end

      wants.json do
        super
      end
    end
  end
end
