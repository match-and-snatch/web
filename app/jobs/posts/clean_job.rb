module Posts
  class CleanJob
    def self.perform
      User.where(['is_profile_owner = ? AND profile_removed_at <= ?', false, 1.month.ago]).joins(:posts).find_each do |user|
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
