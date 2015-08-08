module Flows
  class Event < ActiveSupport::Notifications::Event

    def initialize(name, start, ending, transaction_id, payload)
      super
      @payload = Flows::Payload.new(@payload)
    end

    def performer
      payload[:performer]
    end

    def subject
      payload[:subject]
    end

    def created_at
      payload[:created_at]
    end
  end
end