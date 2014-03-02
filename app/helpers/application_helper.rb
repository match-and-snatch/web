module ApplicationHelper

  # @return [String]
  def current_profile_path
    profile_path(current_user.object)
  end
end
