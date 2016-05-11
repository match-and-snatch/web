class NotificationManager < BaseManager
  BATCH_SIZE = 200

  class << self
    def queue
      :mail
    end

    # @param failure [PaymentFailure]
    def notify_recurring_payment_failed(failure)
      if failure.user.payment_failures(true).
          where("payment_failures.id <> ? AND payment_failures.created_at > ?", failure.id, 3.hours.ago).
          empty?

        subscription = failure.target
        PaymentsMailer.failed(failure).deliver_now if subscription.notify_about_payment_failure?
      end
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
        PostsMailer.mentioned(comment, user).deliver_now
      end
    end

    # @param profile_owner [User]
    def notify_vacation_enabled(profile_owner)
      if profile_owner.subscribers_count >= 15
        ReportsMailer.owner_went_on_vacation(profile_owner).deliver_now
      end

      profile_owner.source_subscriptions.not_removed.joins(:user).find_each(batch_size: BATCH_SIZE) do |subscription|
        ProfilesMailer.vacation_enabled(subscription).deliver_now
      end
    end

    # @param profile_owner [User]
    def notify_vacation_disabled(profile_owner)
      event = profile_owner.events.where(action: 'vacation_mode_enabled').order(:created_at).last
      if event && (event.data[:subscribers_count] || 0) >= 15
        ReportsMailer.owner_returned_from_vacation(profile_owner, event).deliver_now
      end

      profile_owner.source_subscriptions.not_removed.joins(:user).find_each(batch_size: BATCH_SIZE) do |subscription|
        ProfilesMailer.vacation_disabled(subscription).deliver_now
      end
    end
  end
end
