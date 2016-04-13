module Posts
  class CleanJob
    include Concerns::Jobs::Reportable

    PERIOD = 2.months

    def initialize(ids: [])
      @ids = ids
    end

    def perform
      return unless APP_CONFIG['enable_post_clean_job']

      report = new_report users_to_process: processing_users.count,
                          skipped_users: 0,
                          processed_users: 0,
                          removed_posts: 0,
                          removed_uploads: 0,
                          skipped_uploads: 0


      processing_users.find_each do |user|
        event = user.events.where(action: 'profile_page_removed').order(created_at: :desc).first
        if event && event.created_at <= PERIOD.ago
          user.posts.includes(:uploads).find_each do |post|
            unless post.status?
              post.uploads.find_each do |upload|
                delete_s3_files(upload, report)
              end
            end
            post.destroy
            report[:removed_posts] += 1 unless post.persisted?
          end
          user.pending_post_uploads.find_each do |upload|
            delete_s3_files(upload, report)
          end
          report[:processed_users] += 1
        else
          report[:skipped_users] += 1
        end
        puts "[#{Time.zone.now.to_s(:long)}] #{user.email} - #{user.slug} processed" unless Rails.env.test?
      end

      report.forward
    rescue e
      report.log_failure(e.message)
      report.forward
      raise
    end

    private

    def processing_users
      if @ids.any?
        scope = {id: @ids}
      else
        scope = <<-SQL.squish, false, 'profile_page_removed', PERIOD.ago, 0
          (users.is_profile_owner = ?
          AND events.action = ?
          AND events.created_at <= ?
          AND subscribers_count = ?)
        SQL
      end

      User.joins(:posts, :events).where(scope).group('users.id')
    end

    def delete_s3_files(upload, report)
      upload.delete_s3_files!
      if upload.removed?
        report[:removed_uploads] += 1
      else
        report[:skipped_uploads] += 1
      end
    end
  end
end
