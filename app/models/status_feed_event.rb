class StatusFeedEvent < FeedEvent

  def message
    data[:message]
  end

  def title
    'Updated Status'
  end
end