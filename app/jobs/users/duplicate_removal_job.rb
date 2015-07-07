module Users
  class DuplicateRemovalJob

    def perform
      cleanup_by_subscriptions
      cleanup_by_creation_date
      cleanup_by_duplicate_subscriptions
    end

    private

    def cleanup(duplicates)
      duplicates.each do |duplicate|
        unless Rails.env.test?
          puts "\n\n\n"
          puts 'REMOVING=================================================================='
          puts duplicate.inspect
          puts 'Payments:'
          puts duplicate.payments.inspect
        end
        duplicate.destroy unless duplicate.has_profile_page?
      end
    end

    def cleanup_by_duplicate_subscriptions
      DuplicatesPresenter.new.each do |email, users|
        original = users.first

        if users.all? { |u| u.subscriptions.map(&:target_user).sort_by(&:id) == original.subscriptions.map(&:target_user).sort_by(&:id) }
          users.delete(original)
          cleanup(users)
        end
      end
    end

    def cleanup_by_creation_date
      DuplicatesPresenter.new.each do |email, users|
        unsubscribed = users.select { |u| u.subscriptions.count == 0 && !u.has_profile_page? }
        original = unsubscribed.sort_by(&:created_at).first

        if original
          cleanup(unsubscribed - [original])
        end
      end
    end

    def cleanup_by_subscriptions
      DuplicatesPresenter.new.each do |email, users|
        subscribed = users.select { |u| u.subscriptions.count > 0 }
        unsubscribed = users.select { |u| u.subscriptions.count == 0 && !u.has_profile_page? }

        if subscribed.count.zero?
          unsubscribed.delete(unsubscribed.sort_by(&:created_at).first)
        end
        cleanup(unsubscribed)
      end
    end
  end
end
