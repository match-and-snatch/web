class ApiResponsePresenter
  def billing_information_data(subscriptions: [], contributions: [])
    {
      subscriptions: {
        show_status_column: subscriptions.show_failed_column?,
        active: subscriptions.active.map { |subscription| subscription_data(subscription) },
        canceled: subscriptions.canceled.map { |subscription| subscription_data(subscription) }
      },
      contributions: contributions.map do |contribution|
        {
          id: contribution.id,
          target_user: target_user_data(contribution.target_user),
          next_billing_date: contribution.next_billing_date.to_s(:long)
        }
      end
    }
  end

  def subscription_data(subscription)
    {
      id: subscription.id,
      billing_date: subscription.billing_date.to_s(:long),
      canceled_at: subscription.canceled_at ? subscription.canceled_at.to_s(:long) : nil,
      removed: subscription.removed?,
      rejected: subscription.rejected?,
      target_user: target_user_data(subscription.target_user)
    }
  end

  def target_user_data(user)
    {
      id: user.id,
      slug: user.slug,
      name: user.name,
      is_profile_owner: user.is_profile_owner?,
      vacation_enabled: user.vacation_enabled?
    }
  end
end
