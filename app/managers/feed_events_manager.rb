class FeedEventsManager < BaseManager
  attr_reader :user, :target

  # @param user [User]
  # @param target
  def initialize(user: , target: )
    raise ArgumentError unless user.is_a?(User)

    @user = user
    @target = target
  end

  # @return [StatusFeedEvent]
  def create_status_event(message: )
    StatusFeedEvent.create!(subscription_target_user: user, target: target, data: {message: message})
  end

  # @return [AudioFeedEvent]
  def create_audio_event
    AudioFeedEvent.create!(subscription_target_user: user, target: target, data: counts_data)
  end

  # @return [PhotoFeedEvent]
  def create_photo_event
    PhotoFeedEvent.create!(subscription_target_user: user, target: target, data: counts_data)
  end

  # @return [DocumentFeedEvent]
  def create_document_event
    DocumentFeedEvent.create!(subscription_target_user: user, target: target, data: counts_data)
  end

  # @return [VideoFeedEvent]
  def create_video_event
    VideoFeedEvent.create!(subscription_target_user: user, target: target)
  end

  def update_data(data = {})
    events.find_each do |event|
      event.data = event.data.merge(data)
      save_or_die! event
    end
  end

  def update_uploads_log
    self.update_data(counts_data)
  end

  def turn_to_status_event
    events.find_each do |event|
      event.type = 'StatusFeedEvent'
      event.data = {message: target.message}
      save_or_die! event
    end
  end

  private

  def uploads_count
    @uploads_count ||= target.uploads.count
  end

  def events
    FeedEvent.where(target_id: target.id, target_type: 'Post')
  end

  def counts_data
    {
      count: uploads_count,
      label: target.type.underscore.split('_').first.pluralize(uploads_count)
    }
  end
end
