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
    # @yield
    # @return [Event]
    def profile_type_added(user: , profile_type: , &block)
      Event.create! user: user, action: 'profile_type_added', data: { title: profile_type.title }, &block
    end

    # @param user [User]
    # @param profile_type [ProfileType]
    # @yield
    # @return [Event]
    def profile_type_removed(user: , profile_type: , &block)
      Event.create! user: user, action: 'profile_type_removed', data: { title: profile_type.title }, &block
    end

    # @param user [User]
    # @param file [Upload]
    # @yield
    # @return [Event]
    def file_uploaded(user: , file: , &block)
      Event.create! user: user,
                    action: "#{file.type.tableize.singularize}_uploaded",
                    data: { photo_id:    file.id,
                            target_id:   file.uploadable_id,
                            target_type: file.uploadable_type,
                            url:         file.url },
                    &block
    end

    # @param user [User]
    # @param upload [Upload]
    # @yield
    # @return [Event]
    def upload_removed(user: , upload: , &block)
      Event.create! user: user,
                    action: "#{upload.type.tableize.singularize}_removed",
                    data: { target_id:   upload.uploadable_id,
                            target_type: upload.uploadable_type,
                            url:         upload.url },
                    &block
    end

    # @param user [User]
    # @param like [Like]
    # @yield
    # @return [Event]
    def like_created(user: , like: , &block)
      Event.create! user: user,
                    action: 'like_created',
                    data: { likable_id: like.likable_id,
                            target_user_id: like.target_user_id,
                            likable_type: like.likable_type },
                    &block
    end

    # @param user [User]
    # @param like [Like]
    # @return [Integer]
    def like_removed(user: , like: )
      Event.where(user_id: user.id,
                  action: 'like_created')
           .where(['events.data @> ?', { likable_id: like.likable_id,
                                        target_user_id: like.target_user_id,
                                        likable_type: like.likable_type }.to_json]).daily.delete_all
    end

    # @param user [User]
    # @param message [Message]
    # @yield
    # @return [Event]
    def message_created(user: , message: , &block)
      Event.create! user: user,
                    action: 'message_created',
                    data: { id: message.id,
                            target_user_id: message.target_user_id,
                            dialogue_id: message.dialogue_id },
                    &block
    end

    # @param user [User]
    # @param dialogue [Dialogue]
    # @yield
    # @return [Event]
    def dialogue_marked_as_read(user: , dialogue: , &block)
      Event.create! user: user, action: 'dialogue_marked_as_read', data: { dialogue_id: dialogue.id }, &block
    end

    # @param user [User]
    # @param transfer [StripeTransfer]
    # @yield
    # @return [Event]
    def transfer_sent(user: , transfer: , &block)
      Event.create! user: user,
                    action: 'transfer_sent',
                    data: { amount: transfer.amount },
                    &block
    end

    # @param subject [ActiveRecord::Base]
    def delete_events(subject: )
      subject.events.update_all(subject_deleted: true)
    end
  end
end
