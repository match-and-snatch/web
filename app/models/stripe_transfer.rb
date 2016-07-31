class StripeTransfer < ApplicationRecord
  serialize :stripe_response, Hash
  belongs_to :user
  validates :user_id, :amount, presence: true

  def connectpal_fee
    self.subscription_fees
  end
end