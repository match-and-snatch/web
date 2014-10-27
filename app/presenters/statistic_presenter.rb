class StatisticPresenter
  attr_reader :action

  def initialize(graph_type: nil)
    @action = graph_type
  end

  def filter_hash
    { subscriptions: { 'subscription_created'  => 'Subscribers',
                       'subscription_canceled' => 'Unsubscribers' },

      profiles: { 'registered'                => 'Registrations',
                  'profile_created'           => 'Profiles created',
                  'profile_page_removed'      => 'Profiles removed',
                  'subscription_cost_changed' => 'Cost changed',
                  'vacation_mode_enabled'     => 'Vacations' },

      payments: { 'payment_created' => 'Success payments',
                  'payment_failed'  => 'Failed payments',
                  'transfer_sent'   => 'Transfers' },

      posts: { 'status_post_created'   => 'Status posts',
               'audio_post_created'    => 'Audio posts',
               'video_post_created'    => 'Video posts',
               'photo_post_created'    => 'Photo posts',
               'document_post_created' => 'Document posts' } }
  end

  def graph_data
    @graph_data ||= [].tap do |result|
      Event.where(action: @action).
          select('COUNT(id) as events_count, DATE(created_at) as events_date').
          group('events_date').
          order('events_date ASC').each do |event|
        result << { x: event.events_date.to_time.utc.beginning_of_day.to_i, y: event.events_count }
      end
    end
  end
end