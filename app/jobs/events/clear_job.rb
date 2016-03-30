module Events
  class ClearJob
    ACTIONS = %i[cover_picture_changed slug_changed payment_created profile_picture_changed profile_type_removed
                 account_information_changed profile_created comment_hidden benefits_list_updated comment_updated
                 password_restored contribution_created subscription_notifications_disabled profile_name_changed
                 restore_password_requested registered like_created dialogue_marked_as_read message_created logged_in
                 profile_type_added comment_created account_photo_changed subscription_canceled].freeze

    def self.perform
      count = Event.where(action: ACTIONS)
                   .where('created_at <= ?', 2.months.ago)
                   .delete_all

      puts "Deleted #{count} events" unless Rails.env.test?
    end
  end
end
