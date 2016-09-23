class PagesController < ApplicationController
  include MarkdownHelper

  skip_before_action :check_if_tos_accepted, only: [:terms_of_service, :privacy_policy, :faq, :pricing, :contact_us, :crossdomain]
  before_action :render_page

  def crossdomain
  end

  private

  # @return [StaticPage, nil]
  def load_page
    @page = StaticPage.find_by(slug: slug)
  end

  def render_page
    if load_page
      @content = markdown_to_html(@page.content)
      render action: 'show'
    end
  end

  def slug
    @slug ||= request.path.sub('/', '')
  end
end
