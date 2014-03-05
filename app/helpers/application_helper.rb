module ApplicationHelper

  # @param filename [String]
  # @return [String]
  def cloud_image_path(filename)
    if Rails.env.development? && Rails.application.assets.find_asset(filename)
      image_path(filename)
    else
      "//s3-us-west-1.amazonaws.com/buddy-assets/images/#{filename}"
    end
  end

  # @return [String]
  def current_profile_path
    profile_path(current_user.object)
  end
end
