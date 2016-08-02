class PopulateTosAcceptances < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        puts "started at #{Time.zone.now.to_s(:long)}"

        created_date = Event.where(action: 'tos_accepted').order(created_at: :asc).first.try(:created_at) || Time.zone.now

        tos_text = File.exist?('public/tos.txt') ? File.read('public/tos.txt') : ''
        version = TosVersion.order(created_at: :desc).first || TosVersion.create(tos: tos_text,
                                                                                 published_at: created_date,
                                                                                 created_at: created_date,
                                                                                 updated_at: created_date)
        query = Event.includes(:user).where(action: 'tos_accepted')

        i = 0
        total = query.count

        query.find_in_batches do |group|
          params = []
          group.each do |event|
            params << {user_id: event.user_id,
                       user_email: event.user.email,
                       user_full_name: event.user.full_name,
                       created_at: event.created_at,
                       updated_at: event.created_at}
            i += 1
          end
          TosAcceptance.create(params) do |r|
            r.tos_version_id = version.id
          end
          puts "processed #{i} from #{total}"
        end
        puts "finished at #{Time.zone.now.to_s(:long)}"
      end
    end
  end
end
