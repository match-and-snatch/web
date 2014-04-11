class ProfileTypeManager < BaseManager

  # @param title [String]
  def create(title: nil)
    fail_with! title: :empty if title.blank?
    fail_with! title: :taken if ProfileType.where(title: title).any?

    ProfileType.create(title: title).tap do |profile_type|
      profile_type.valid? or fail_with!(profile_type.errors)
    end
  end
end