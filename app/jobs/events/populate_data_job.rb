module Events
  class PopulateDataJob
    def self.perform
      query = Event.where('old_data IS NOT ? AND old_data != ?', nil, {}.to_yaml).where("data = ?", {}.to_json)

      i = 0
      total = query.count

      query.find_in_batches do |group|
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
