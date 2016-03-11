class NotificationManager < BaseManager
  BATCH_SIZE = 200

  class << self
    def queue
      :mail
    end

    # @param contribution [Contribution]
    def notify_contributed(contribution)
      target_user = contribution.target_user
      unless target_user.locked? && target_user.lock_type == 'tos'
        ContributionsMailer.received(contribution).deliver_now
      end
      ContributionsMailer.sent(contribution).deliver_now
    end

    # @param post [Post]
    def notify_post_created(post)
      if post.user.notifications_debug_enabled?
        PostsMailer.created(post, post.user).deliver_now
      end

      post.user.source_subscriptions.where(notifications_enabled: true).not_removed.preload(:user).find_each(batch_size: BATCH_SIZE) do |s|
        begin
          PostsMailer.created(post, s.user).deliver_now if s.user && post && !s.user.locked?
        rescue
          puts "Something is wrong with subscription ##{s.id}"
        end
      end
    end

    # @param comment [Comment]
    def notify_comment_created(comment)
      comment.mentioned_users.where(locked: false).find_each(batch_size: BATCH_SIZE) do |user|
        PostsMailer.mentioned(user, Flows::Payload.new(subject: comment)).deliver_now
      end
    end

    # @param profile_owner [User]
    def notify_vacation_enabled(profile_owner)
      profile_owner.source_subscriptions.not_removed.joins(:user).find_each(batch_size: BATCH_SIZE) do |subscription|
        ProfilesMailer.vacation_enabled(subscription).deliver_now
      end
    end

    # @param profile_owner [User]
    def notify_vacation_disabled(profile_owner)
      profile_owner.source_subscriptions.not_removed.joins(:user).find_each(batch_size: BATCH_SIZE) do |subscription|
        ProfilesMailer.vacation_disabled(subscription).deliver_now
      end
    end
  end
end
