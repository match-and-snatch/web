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
    StatusFeedEvent.create! subscription_target_user: user,
                            target: target,
                            data: {message: message}
  end

  # @return [AudioFeedEvent]
  def create_audio_event
    AudioFeedEvent.create! subscription_target_user: user,
                           target: target,
                           data: {count: uploads_count, label: 'audio'.pluralize(uploads_count)}
  end

  # @return [PhotoFeedEvent]
  def create_photo_event
    PhotoFeedEvent.create! subscription_target_user: user,
                           target: target,
                           data: {count: uploads_count, label: 'photo'.pluralize(uploads_count)}
  end

  # @return [DocumentFeedEvent]
  def create_document_event
    DocumentFeedEvent.create! subscription_target_user: user,
                              target: target,
                              data: {count: uploads_count, label: 'document'.pluralize(uploads_count)}
  end

  # @return [VideoFeedEvent]
  def create_video_event
    VideoFeedEvent.create! subscription_target_user: user,
                           target: target
  end

  private

  def uploads_count
    @uploads_count ||= target.uploads.count
  end
end
