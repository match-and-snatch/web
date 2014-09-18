module Events
  class PopulateJob
    def self.perform
      Post.where(type: nil).update_all(type: 'StatusPost')

      User.find_each do |user|
        EventsManager.user_logged_in(user: user)
        EventsManager.user_registered(user: user)

        EventsManager.profile_created(user: user, data: { cost: user.cost, profile_name: user.profile_name }) if user.has_profile_page?

        user.uploads.photos.each do |photo|
          type = photo.transloadit_data['results'][':original'][0]['field']
          if type == 'profile_picture_file'
            EventsManager.profile_picture_changed(user: user, picture: photo)
          elsif type == 'cover_picture_file'
            EventsManager.cover_picture_changed(user: user, picture: photo)
          elsif type == 'account_picture_file'
            EventsManager.account_photo_changed(user: user, photo: photo)
          end
        end

        EventsManager.subscription_cost_changed(user: user, from: 5, to: user.cost) if user.has_profile_page? && user.cost != 5
        EventsManager.benefits_list_updated(user: user, benefits: user.benefits.map(&:message)) if user.benefits.any?

        user.uploads.audios.each do |audio|
          EventsManager.welcome_media_added(user: user, media: audio)
        end
        user.uploads.videos.each do |video|
          EventsManager.welcome_media_added(user: user, media: video)
        end

        EventsManager.payout_information_changed(user: user) unless user.routing_number.nil?
        EventsManager.account_information_changed(user: user, data: { full_name:    user.full_name,
                                                                      company_name: user.company_name,
                                                                      email:        user.email }) if user.company_name.present?
        EventsManager.contact_info_changed(user: user,
                                           info: user.contacts_info)       if user.contacts_info.present?
        EventsManager.credit_card_updated(user: user)                      if user.last_four_cc_numbers.present?
        EventsManager.vacation_mode_enabled(user: user,
                                            reason: user.vacation_message) if user.vacation_enabled?

        user.comments.find_each do |comment|
          EventsManager.comment_created(user: user, comment: comment)
          EventsManager.comment_hidden(user: user, comment: comment) if comment.hidden?
          EventsManager.comment_updated(user: user, comment: comment) if comment.created_at != comment.updated_at
        end

        user.payments.find_each do |payment|
          EventsManager.payment_created(user: user, payment: payment)
        end
        user.payment_failures.find_each do |payment_failure|
          EventsManager.payment_failed(user: user, payment_failure: payment_failure)
        end

        user.posts.find_each do |post|
          EventsManager.post_created(user: user, post: post)
          EventsManager.post_hidden(user: user, post: post) if post.hidden?
        end

        user.subscriptions.find_each do |subscription|
          EventsManager.subscription_created(user: user, subscription: subscription)
          EventsManager.subscription_notifications_disabled(user: user, subscription: subscription) unless subscription.notifications_enabled?
        end

        user.profile_types.each do |type|
          EventsManager.profile_type_added(user: user, profile_type: type)
        end

        user.likes.find_each do |like|
          EventsManager.like_created(user: user, like: like)
        end

        user.messages.find_each do |message|
          EventsManager.message_created(user: user, message: message)
        end

        StripeTransfer.where(user_id: user.id).each do |transfer|
          EventsManager.transfer_sent(user: user, transfer: transfer)
        end

        Upload.where(user_id: user.id).where.not(uploadable_type: 'User').each do |upload|
          EventsManager.file_uploaded(user: user, file: upload)
        end
      end
    end

    private

    def fix_transloadit_data
      ActiveRecord::Base.connection.execute <<-SQL
        UPDATE uploads
        SET transloadit_data = REPLACE (transloadit_data, ' !ruby/hash:ActionController::ManagebleParameters', '')
        WHERE transloadit_data LIKE '%!ruby/hash:ActionController::ManagebleParameters%'
      SQL
    end
  end
end