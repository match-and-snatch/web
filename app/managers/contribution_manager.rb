class ContributionManager < BaseManager
  # @param user [User]
  # @param target_user [User]
  def initialize(user: , contribution: nil)
    @user = user
    @contribution = contribution
  end

  # @param target_user [User]
  # @param amount [Integer, String]
  # @param message [String, nil]
  # @return [Contribution]
  def create(target_user: , amount: nil, recurring: false, message: nil)
    amount = amount.to_i
    fail_with! amount: :zero if amount < 1
    if limit_reached?(amount)
      unless @user.contribution_requests.pending.any?
        @user.contribution_requests.create!(target_user: target_user,
                                            amount: amount,
                                            recurring: recurring,
                                            message: message)
      end
      fail_with! amount: :contribution_limit_reached
    end

    @contribution = create_contribution(target_user: target_user,
                                        amount: amount,
                                        recurring: recurring)

    fail_with! 'Payment has been failed' if @contribution.new_record?

    if message.present?
      MessagesManager.new(user: @user).create(target_user: target_user,
                                              message: message,
                                              contribution: @contribution)
    end

    @contribution
  end

  # Creates child from recurring contribution
  def create_child
    raise ArgumentError, 'Requires recurring contribution' unless @contribution.try(:recurring?)
    create_contribution(target_user: @contribution.target_user,
                        amount: @contribution.amount,
                        recurring: false,
                        parent: @contribution).tap do
      @contribution.touch
    end
  end

  def delete
    EventsManager.contribution_cancelled(user: @user, contribution: @contribution)
    @contribution.destroy
  end

  def approve!(contribution_request)
    UserManager.new(@user).update_daily_subscriptions_limit(limit: 50000)
    contribution_request.approve!
  end

  private

  def limit_reached?(amount)
    return true if amount > @user.daily_contributions_limit

    recently_contributed = Contribution.where(user: @user)
                             .where("created_at > ?", 24.hours.ago)
                             .sum(:amount)

    recently_contributed + amount > @user.daily_contributions_limit
  end

  def create_contribution(target_user: , amount: , recurring: , parent: nil)
    contribution = Contribution.new(user: @user, target_user: target_user, amount: amount, recurring: recurring, parent: parent)

    ActiveRecord::Base.transaction do
      contribution.save!
      PaymentManager.new(user: @user).create_charge(amount: amount,
                                                    customer: @user.stripe_user_id,
                                                    description: "Contribution #{target_user.profile_name.first(20)}",
                                                    statement_description: 'Contribution',
                                                    metadata: {target_id: contribution.id, target_type: contribution.class.name, user_id: @user.id})
      EventsManager.contribution_created(user: @user, contribution: contribution)
      ContributionFeedEvent.create! subscription_target_user: @user, target_user: target_user, target: contribution, data: {recurring: recurring, amount: (amount / 100).to_i}
      NotificationManager.delay.notify_contributed(contribution)
      contribution
    end
  rescue Stripe::StripeError
    EventsManager.contribution_failed(user: @user, contribution: contribution)
    UserManager.new(@user).mark_billing_failed
  rescue ManagerError
    EventsManager.contribution_failed(user: @user, contribution: contribution)
    raise
  ensure
    return contribution
  end
end
