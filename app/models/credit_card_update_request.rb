class CreditCardUpdateRequest < Request
  scope :recent, -> { where('created_at > ?', 24.hours.ago) }
end
