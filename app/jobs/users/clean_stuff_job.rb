module Users
  class CleanStuffJob
    include Concerns::Jobs::Reportable

    # TODO (DJ):
    # benefits
    # comment_ignores
    # contributions
    # credit_card_declines
    # dialogues_users
    # events
    # messages
    # payments
    # payment_failures
    # pending_posts
    # posts
    # profile_pages
    # profile_types_users
    # refunds
    # requests
    # stripe_transfers
    # subscriptions
    # subscription_daily_count_change_events
    # top_profiles
    # uploads
    def perform
      @report = new_report(deleted_comments: 0, deleted_likes: 0)

      clean_comments
      clean_likes

      report.forward
    rescue => e
      report.log_failure(e.message)
      report.forward
      raise
    end

    private

    def clean_comments
      Comment.joins(sql('comments')).where(users: {id: nil}).find_each do |comment|
        number_of_replies = comment.replies.count
        comment.replies.delete_all
        comment.delete

        report[:deleted_comments] += (1 + number_of_replies)
      end
    end

    def clean_likes
      report[:deleted_likes] = Like.joins(sql('likes')).where(users: {id: nil}).delete_all
    end

    def sql(table_name)
      "LEFT OUTER JOIN users ON users.id = #{table_name}.user_id"
    end
  end
end
