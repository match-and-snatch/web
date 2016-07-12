module Events
  class PopulateDataJob
    def self.perform
      i = 0
      total = Payment.count

      Event.where.not(old_data: nil).where("data = ?", {}.to_json).find_in_batches do |group|
        group.each do |event|
          data = YAML.load(event.old_data)
          next if data.blank?
          event.update_column :data, data
          i += 1
        end
        puts "processed #{i} from #{total}" unless Rails.env.test?
      end
    end
  end
end
