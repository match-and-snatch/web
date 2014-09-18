class EventsManager < BaseManager
  extend Concerns::Events::AccountTracker
  extend Concerns::Events::SessionTracker
  extend Concerns::Events::ProfileTracker
  extend Concerns::Events::CommentTracker
  extend Concerns::Events::PaymentTracker
  extend Concerns::Events::PostTracker
  extend Concerns::Events::SubscriptionTracker

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
    # @param file [Upload]
    def file_uploaded(user: , file: )
      Event.create! user: user,
                    action: "#{file.type.tableize}_uploaded",
                    data: { photo_id:    file.id,
                            target_id:   file.uploadable_id,
                            target_type: file.uploadable_type,
                            url:         file.url }
    end

    # @param user [User]
    # @param upload [Upload]
    def upload_removed(user: , upload: )
      Event.create! user: user,
                    action: "#{upload.type.tableize}_destroyed",
                    data: { photo_id:    upload.id,
                            target_id:   upload.uploadable_id,
                            target_type: upload.uploadable_type,
                            url:         upload.url }
    end

    # @param user [User]
    # @param like [Like]
    def like_created(user: , like: )
      Event.create! user: user,
                    action: 'like_created',
                    data: { likable_id: like.likable_id,
                            target_user_id: like.target_user_id,
                            likable_type: like.likable_type }
    end

    # @param user [User]
    # @param like [Like]
    def like_removed(user: , like: )
      Event.where(user_id: user.id,
                  action: 'like_created',
                  data: { likable_id: like.likable_id,
                          target_user_id: like.target_user_id,
                          likable_type: like.likable_type }.to_yaml).daily.delete_all
    end

    # @param user [User]
    # @param message [Message]
    def message_created(user: , message: )
      Event.create! user: user,
                    action: 'message_created',
                    data: { id: message.id,
                            target_user_id: message.target_user_id,
                            dialogue_id: message.dialogue_id }
    end

    # @param user [User]
    def dialogue_marked_as_read(user: , dialogue: )
      Event.create! user: user, action: 'dialogue_marked_as_read', data: { dialogue_id: dialogue.id }
    end

    # @param user [User]
    # @param transfer [StripeTransfer]
    def transfer_sent(user: , transfer: )
      Event.create! user: user,
                    action: 'transfer_sent',
                    data: { amount: transfer.amount }
    end
  end
end