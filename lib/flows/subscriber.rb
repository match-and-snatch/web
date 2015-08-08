module Flows
  module Subscriber

    # @param event_date [String, Symbol]
    def self.subscribe(event_name)
      if block_given?
        ActiveSupport::Notifications.subscribe(event_name.to_s) do |*args|
          event = Flows::Event.new(*args)
          yield(event)
        end
      end
    end
  end
end