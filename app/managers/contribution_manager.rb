class ContributionManager < BaseManager

  # @param user [User]
  # @param target_user [User]
  def initialize(user: , contribution: nil)
    @user = user
    @contribution = contribution
  end

  # @param target_user [User]
  # @param amount [Integer, String]
  # @return [Contribution]
  def create(target_user: , amount: nil, recurring: false)
    amount = amount.to_i
    fail_with! amount: :zero if amount < 1
    @contribution = create_contribution(target_user: target_user, amount: amount, recurring: recurring)
  end

  # Creates child from recurring contribution
  def create_child
    raise ArgumentError, 'Requires recurring contribution' unless @contribution.try(:recurring?)
    create_contribution(target_user: @contribution.target_user, amount: @contribution.amount, recurring: false, parent: @contribution)
  end

  def delete
    EventsManager.contribution_cancelled(user: @user, contribution: @contribution)
    @contribution.destroy
  end

  private

  def create_contribution(target_user: , amount: , recurring: , parent: nil)
    contribution = Contribution.create!(user: @user, target_user: target_user, amount: amount, recurring: recurring, parent: parent)
    PaymentManager.new(user: @user).create_charge(amount: amount,
                                                  customer: @user.stripe_user_id,
                                                  description: "Contribution #{target_user.profile_name.first(20)}",
                                                  statement_description: 'Contribution',
                                                  metadata: {target_id: contribution.id, target_type: contribution.class.name, user_id: @user.id})
    EventsManager.contribution_created(user: @user, contribution: contribution)
    contribution
  rescue Stripe::StripeError => e
    EventsManager.contribution_failed(user: @user, contribution: contribution)
    contribution.try(:destroy)
    contribution
  end
end
