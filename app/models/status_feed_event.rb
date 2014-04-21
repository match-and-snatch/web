class StatusFeedEvent < Feedevent

  def message
    data['message']
  end
end