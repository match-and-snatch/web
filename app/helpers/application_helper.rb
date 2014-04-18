module ApplicationHelper

  if Rails.env.development?
    # @overload
    # @param source [String] relative path to asset
    # @param options [Hash]
    # @return [String, nil]
    def compute_asset_host(source, options = {})
      fname = source.split('/').last
      return if Rails.application.assets.find_asset(fname)

      super(source, options)
    end
  end

  # @return [String]
  def current_profile_path
    profile_path(current_user.object)
  end

  # @param text [String]
  # @return [String]
  def super_highlight(text)
    q = params[:q]
    if q.present?
      highlights = q.split(/\W+/).reject { |token| token.length < 3} << q
      highlight(text, highlights)
    else
      text
    end
  end

  # Returns number displaying subscription cost
  # @param cost [Integer, Float, String]
  # @return [String]
  def super_number_to_currency(cost, *args)
    cost = cost.to_f
    ceil_cost = cost.to_i
    cost - ceil_cost > 0 ? number_to_currency(cost, *args) : ceil_cost
  end

  # @param profile [ProfileDecorator]
  # @return [String]
  def render_benefits(profile)
    render '/benefits/list', benefits: profile.benefits
  end

  # @param user [User]
  # @return [String]
  def link_to_user(user)
    link_to_if user.has_profile_page?, user.full_name, profile_path(user)
  end
end
