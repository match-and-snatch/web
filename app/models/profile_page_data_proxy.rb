class ProfilePageDataProxy < Struct.new(:user)

  # @param attributes [Hash]
  # @return [ProfilePage]
  def update!(attributes)
    ActiveRecord::Base.transaction do
      if profile_page
        profile_page.attributes = attributes
      else
        @profile_page = ProfilePage.new(attributes.merge(user_id: user.id))
      end

      profile_page.save!.tap do |result|
        user.has_custom_profile_page_css = profile_page.css.present?
        user.has_custom_welcome_message = profile_page.welcome_box.present?
        user.has_special_offer = profile_page.special_offer.present?
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

  # @return [String, nil]
  def special_offer
    if user.has_special_offer?
      profile_page.special_offer
    end
  end

  private

  def profile_page
    @profile_page ||= user.profile_page
  end
end
