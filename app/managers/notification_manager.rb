class NotificationManager < BaseManager
  class << self
    def queue
      :mail
    end

    # @param contribution [Contribution]
    def notify_contributed(contribution)
      ContributionsMailer.received(contribution).deliver
      ContributionsMailer.sent(contribution).deliver
    end

    # @param post [Post]
    def notify_post_created(post)
      if post.user.notifications_debug_enabled?
        PostsMailer.created(post, post.user).deliver
      end

      post.user.source_subscriptions.where(notifications_enabled: true).not_removed.preload(:user).find_each do |s|
        begin
          PostsMailer.created(post, s.user).deliver if s.user && post
        rescue
          puts "Something is wrong with subscription ##{s.id}"
        end
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
