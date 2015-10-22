module Events
  class PopulateSubjectsJob
    def self.perform
      Event.where(action: 'subscription_canceled', subject_id: nil, subject_type: nil).find_each(batch_size: 1000).with_index do |event, index|
        event.update_columns(subject_id: event.data[:target_user_id], subject_type: 'User')
        puts "Processed #{index} records" if !Rails.env.test? && (index % 1000).zero?
      end
      puts "Processed #{Event.where(action: 'subscription_canceled').count} records" unless Rails.env.test?
    end
  end
end
