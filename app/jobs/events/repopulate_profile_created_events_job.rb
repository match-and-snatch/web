module Events
  class RepopulateProfileCreatedEventsJob
    def self.perform
      Event.where(action: 'profile_created', created_at: Date.new(2014, 10, 20)..Date.new(2014, 10, 21)).delete_all

      User.profile_owners.find_each do |user|
        EventsManager.profile_created(user: user, data: { cost: user.cost, profile_name: user.profile_name }) do |event|
          event.created_at = user.created_at
          event.updated_at = user.created_at
        end
      end
    end
  end
end