class NotificationManager < BaseManager
  class << self
    def queue
      :mail
    end

    # @param post [Post]
    def notify_post_created(post)
      post.user.source_subscriptions.where(notifications_enabled: true).not_removed.preload(:user).find_each do |s|
        PostsMailer.created(post, s.user).deliver if s.user && post
      end
    end

    # @param comment [Comment]
    def notify_comment_created(comment)
      comment.mentioned_users.find_each do |user|
        PostsMailer.mentioned(comment, user).deliver
      end
    end

    # @param profile_owner [User]
    def notify_vacation_enabled(profile_owner)
      profile_owner.source_subscriptions.not_removed.joins(:user).find_each do |subscription|
        ProfilesMailer.vacation_enabled(subscription).deliver
      end
    end

    # @param profile_owner [User]
    def notify_vacation_disabled(profile_owner)
      profile_owner.source_subscriptions.not_removed.joins(:user).find_each do |subscription|
        ProfilesMailer.vacation_disabled(subscription).deliver
      end
    end
  end
end