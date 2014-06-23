class StripeTransfer < ActiveRecord::Base
  serialize :stripe_response, Hash
  belongs_to :user
  validates :user_id, :amount, presence: true
end