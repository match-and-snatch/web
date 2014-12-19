module Concerns::CreditCardValidator

  # @param card [CreditCard]
  def validate_cc(card)
    fail_with :number if card.number.blank? || card.number.length < 14
    fail_with :cvc if card.cvc.blank? || card.cvc.length < 3
    fail_with :expiry_date if card.expiry_month.blank? || card.expiry_year.blank? || card.expiry_month.to_i > 12 || card.expiry_month.to_i < 1 || card.expiry_year.to_i < 14
    fail_with zip: :empty if card.zip.blank?
    fail_with city: :empty if card.city.blank?
    fail_with state: :empty if card.state.blank?
    fail_with address_line_1: :empty if card.address_line_1.blank?
    #fail_with address_line_2: :empty if card.address_line_2.blank?
  end
end
