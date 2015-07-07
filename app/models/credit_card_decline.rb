class CreditCardDecline < ActiveRecord::Base
  belongs_to :user
  validates :stripe_fingerprint, presence: true
end