module Concerns::SubscriberBenefitsHandler
  # @param benefits [Array<String>]
  # @return [User]
  def update_benefits(benefits)
    fail_with! :benefits if benefits.nil?

    user.benefits.clear

    benefits.each do |ordering, message|
      user.benefits.create!(message: message, ordering: ordering) if message.present?
    end
    EventsManager.benefits_list_updated(user: user, benefits: user.benefits.map(&:message))

    user
  end

  # @return [User]
  def hide_benefits
    fail_with! 'Welcome media already hidden' unless user.benefits_visible?

    user.benefits_visible = false
    save_or_die! user
  end

  # @return [User]
  def show_benefits
    fail_with! 'Welcome media already visible' if user.benefits_visible?

    user.benefits_visible = true
    save_or_die! user
  end

  # @param ids [Array]
  def self.hide_benefits(ids = [])
    raise BulkEmptySetError, 'No users selected' if ids.blank?

    ActiveRecord::Base.transaction do
      User.where(id: ids, benefits_visible: true).find_each do |user|
        UserProfileManager.new(user).hide_benefits
      end
    end
  end

  # @param ids [Array]
  def self.show_benefits(ids = [])
    raise BulkEmptySetError, 'No users selected' if ids.blank?

    ActiveRecord::Base.transaction do
      User.where(id: ids, benefits_visible: false).find_each do |user|
        UserProfileManager.new(user).show_benefits
      end
    end
  end
end
