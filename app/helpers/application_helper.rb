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
end
