class CreditCardDecline < ApplicationRecord
  belongs_to :user
  validates :stripe_fingerprint, presence: true
end