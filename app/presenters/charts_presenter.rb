class ChartsPresenter
  attr_reader :action

  FILTER_HASH = { subscriptions: { 'subscription_created'  => 'Subscribers',
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

  # @param graph_type [String]
  def initialize(graph_type: nil)
    @action = graph_type
  end

  # @return [Hash<String, String>]
  def filter_hash
    FILTER_HASH
  end

  # @return [String, nil]
  def data_label
    FILTER_HASH.values.inject(:merge)[@action]
  end

  # Returns array of hashes with dates and number of events
  # @return [Array<Hash<x: Integer, y: Integer>>]
  def chart_data
    @chart_data ||= [].tap do |result|
      Event.where(action: @action).group('DATE(created_at)').order('date_created_at ASC').count.each do |date, count|
        result << { x: date.to_time.utc.beginning_of_day.to_i, y: count }
      end
    end
  end
end