class EventsManager < BaseManager
  extend Concerns::AccountEventsTracker
  extend Concerns::SessionEventsTracker
  extend Concerns::ProfileEventsTracker
  extend Concerns::CommentEventsTracker
  extend Concerns::PaymentEventsTracker
  extend Concerns::PostEventsTracker
  extend Concerns::SubscriptionEventsTracker

  class << self
    # @param user [User]
    # @param profile_type [ProfileType]
    def profile_type_added(user: , profile_type: nil)
      Event.create! user: user, action: 'profile_type_added', data: { title: profile_type.title }
    end

    # @param user [User]
    # @param profile_type [ProfileType]
    def profile_type_removed(user: , profile_type: nil)
      Event.create! user: user, action: 'profile_type_removed', data: { title: profile_type.title }
    end

    # @param user [User]
    # @param file [Audio, Video, Photo, Document]
    def file_uploaded(user: , file: )
      Event.create! user: user, action: "#{file.type.tableize}_uploaded", data: { id: file.id, type: file.type }
    end

    # @param user [User]
    # @param upload [Upload]
    def upload_removed(user: , upload: )
      Event.create! user: user, action: "#{upload.type.tableize}_destroyed", data: { id: upload.id, type: upload.type }
    end

    # @param user [User]
    # @param like [Like]
    def like_created(user: , like: )
      Event.create! user: user, action: 'like_created', data: { likable_id: like.likable_id, likable_type: like.likable_type }
    end

    # @param user [User]
    # @param like [Like]
    def like_removed(user: , like: )
      Event.where(user_id: user.id, action: 'like_created', data: { likable_id: like.likable_id, likable_type: like.likable_type }.to_yaml).daily.delete_all
    end

    # @param user [User]
    # @param message [Message]
    def message_created(user: , message: )
      Event.create! user: user, action: 'message_created', data: { target_user_id: message.target_user_id }
    end

    # @param user [User]
    def dialogue_marked_as_read(user: )
      Event.create! user: user, action: 'dialogue_marked_as_read'
    end

    # @param recipient [User]
    def transfer_sent(recipient: )
      Event.create! user: recipient, action: 'transfer_sent'
    end
  end
end