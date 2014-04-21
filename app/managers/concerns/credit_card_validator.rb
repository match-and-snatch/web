module Concerns::CreditCardValidator

  # @param card [CreditCard]
  def validate_cc(card)
    fail_with :number      if card.number.blank? || card.number.length < 14
    fail_with :cvc         if card.cvc.blank?    || card.cvc.length    < 3
    fail_with :expiry_date if card.expiry_month.blank? || card.expiry_year.blank? || card.expiry_month.to_i > 12 || card.expiry_month.to_i < 1 || card.expiry_year.to_i < 14
  end
end
