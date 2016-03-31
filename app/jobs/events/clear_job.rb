module Events
  class ClearJob
    ACTIONS = %i[cover_picture_changed slug_changed profile_picture_changed profile_type_removed
                 account_information_changed comment_hidden benefits_list_updated comment_updated
                 password_restored subscription_notifications_disabled profile_name_changed
                 restore_password_requested like_created dialogue_marked_as_read message_created logged_in
                 profile_type_added comment_created account_photo_changed].freeze

    def self.perform
      count = Event.where(action: ACTIONS)
                   .where('created_at <= ?', 2.months.ago)
                   .delete_all

      puts "Deleted #{count} events" unless Rails.env.test?
    end
  end
end
