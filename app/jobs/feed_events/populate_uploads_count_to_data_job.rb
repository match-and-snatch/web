module FeedEvents
  class PopulateUploadsCountToDataJob
    def self.perform
      AudioFeedEvent.find_each(batch_size: 1000).with_index do |event, index|
        next unless event.target

        uploads_count = event.target.uploads.count

        event.data = event.data.merge(count: uploads_count, label: 'audio'.pluralize(uploads_count))
        event.save!

        puts "Processed #{index} records" if !Rails.env.test? && (index % 1000).zero?
      end
      puts 'Processed Audio Feed Events records' unless Rails.env.test?

      PhotoFeedEvent.find_each(batch_size: 1000).with_index do |event, index|
        next unless event.target

        uploads_count = event.target.uploads.count

        event.data = event.data.merge(count: uploads_count, label: 'photo'.pluralize(uploads_count))
        event.save!

        puts "Processed #{index} records" if !Rails.env.test? && (index % 1000).zero?
      end
      puts 'Processed Photo Feed Events records' unless Rails.env.test?

      DocumentFeedEvent.find_each(batch_size: 1000).with_index do |event, index|
        next unless event.target

        uploads_count = event.target.uploads.count

        event.data = event.data.merge(count: uploads_count, label: 'document'.pluralize(uploads_count))
        event.save!

        puts "Processed #{index} records" if !Rails.env.test? && (index % 1000).zero?
      end
      puts 'Processed Document Feed Events records' unless Rails.env.test?
    end
  end
end
