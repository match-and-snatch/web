module Flows
  class Publisher

    class << self
      def queue
        :mail
      end

      # @param event_date [String, Symbol]
      # @param payload [Flows::Payload]
      def broadcast(event_name, payload = nil)
        payload ||= Flows::Payload.new

        if Rails.application.config.notifications_enabled
          event_name = event_name.to_s

          if block_given?
            ActiveSupport::Notifications.instrument(event_name, payload) do
              yield
            end
          else
            ActiveSupport::Notifications.instrument(event_name, payload)
          end
        end
      end

      # @param event_name [String, Symbol]
      # @param performer [Flows::CompactData, Flows::CompactData::CompactHash]
      # @param timestamp [Integer]
      # @param payload [Flows::Event]
      def notify(event_name, performer, timestamp, payload)
        payload = payload.unpack
        payload = {subject: payload} unless payload.is_a?(Hash)
        payload[:performer] = performer.unpack
        payload[:time] = Time.zone.at(timestamp)

        ::Flows::Publisher.broadcast(event_name, Flows::Payload.new(payload))
      end
      handle_asynchronously :notify

    end
  end
end