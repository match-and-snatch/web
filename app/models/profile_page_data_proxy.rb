class ProfilePageDataProxy < Struct.new(:user)

  # @param attributes [Hash]
  # @return [ProfilePage]
  def update!(attributes)
    ActiveRecord::Base.transaction do
      if profile_page
        profile_page.attributes = attributes
      else
        @profile_page = ProfilePage.new(attributes, user: user)
      end

      profile_page.save!.tap do |result|
        user.has_custom_profile_page_css = profile_page.css.present?
        user.has_custom_welcome_message = profile_page.welcome_box.present?
        user.save!
      end
    end
  end

  # @return [String, nil]
  def css
    if user.has_custom_profile_page_css?
      profile_page.css
    end
  end

  # @return [String, nil]
  def welcome_box
    if user.has_custom_welcome_message?
      profile_page.welcome_box
    end
  end

  private

  def profile_page
    @profile_page ||= user.profile_page
  end
end
