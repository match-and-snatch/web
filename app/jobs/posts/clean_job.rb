module Posts
  class CleanJob
    PERIOD = 2.months

    def self.perform
      return if Rails.env.staging?

      sql = <<-SQL.squish, false, 'profile_page_removed', PERIOD.ago, 0
        (users.is_profile_owner = ?
        AND events.action = ?
        AND events.created_at <= ?
        AND subscribers_count = ?)
      SQL

      User.joins(:posts, :events).where(sql).group('users.id').find_each do |user|
        event = user.events.where(action: 'profile_page_removed').order(created_at: :desc).first
        if event && event.created_at <= PERIOD.ago
          user.posts.includes(:uploads).find_each do |post|
            unless post.status?
              post.uploads.find_each do |upload|
                upload.delete_s3_files!
              end
            end
            post.destroy
          end
        end
      end
    end
  end
end
