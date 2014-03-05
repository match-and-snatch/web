module ApplicationHelper

  # @overload
  # @param source [String] relative path to asset
  # @param options [Hash]
  # @return [String, nil]
  def compute_asset_host(source, options = {})
    if Rails.env.development?
      fname = source.split('/').last
      return if Rails.application.assets.find_asset(fname)
    end

    super(source, options)
  end

  # @return [String]
  def current_profile_path
    profile_path(current_user.object)
  end
end
