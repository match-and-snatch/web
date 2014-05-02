class PhotoFeedEvent < FeedEvent

  def message
    count = target.uploads.count
    label = 'photo'.pluralize(count)
    I18n.t(self.class.label, scope: :feed, count: count, label: label)
  end
end