class EventsManager < BaseManager
  class << self
    def track_login(user: )
      Event.create! user: user, action: 'logged_in'
    end

    def track_logout(user: )
      Event.create! user: user, action: 'logged_out'
    end

    def track_registration(user: )
      Event.create! user: user, action: 'registered'
    end

    def track_change_cost(user: , from: , to: )
      data = { from: from, to: to }
      Event.create! user: user, action: 'cost_changed', data: data
    end
  end
end