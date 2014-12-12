module Posts
  class CleanJob
    def self.perform
      return if Rails.env.staging?

      User.joins(:posts, :events).where(['users.is_profile_owner = ? AND events.action = ? AND events.created_at <= ?', false, 'profile_page_removed', 1.month.ago]).find_each do |user|
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
