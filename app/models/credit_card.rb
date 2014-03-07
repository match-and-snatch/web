class CreditCard
  attr_reader :number, :cvc, :expiry_month, :expiry_year

  # @param number [String]
  # @param cvc [String]
  # @param expiry_month [String]
  # @param expiry_year [String]
  def initialize(number: nil, cvc: nil, expiry_month: nil, expiry_year: nil)
    @number       = number      .to_s.gsub /\D/, ''
    @cvc          = cvc         .to_s.gsub /\D/, ''
    @expiry_month = expiry_month.to_s.gsub /\D/, ''
    @expiry_year  = expiry_year .to_s.gsub /\D/, ''
  end

  # @return [Hash]
  def to_stripe
    {number: number, cvc: cvc, exp_month: expiry_month, exp_year: expiry_year}
  end
end
