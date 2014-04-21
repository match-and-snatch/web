class StatusFeedEvent < FeedEvent

  def message
    data[:message]
  end
end