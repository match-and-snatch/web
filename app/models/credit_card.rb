class CreditCard
  attr_reader :number, :cvc, :expiry_month, :expiry_year, :address_line_1, :address_line_2, :city, :zip, :state, :holder_name

  # @param number [String]
  # @param cvc [String]
  # @param expiry_month [String]
  # @param expiry_year [String]
  def initialize(number: nil, cvc: nil, expiry_month: nil, expiry_year: nil, zip: nil, city: nil, state: nil, address_line_1: nil, address_line_2: nil, holder_name: nil)
    @number       = number      .to_s.gsub /\D/, ''
    @cvc          = cvc         .to_s.gsub /\D/, ''
    @expiry_month = expiry_month.to_s.gsub /\D/, ''
    @expiry_year  = expiry_year .to_s.gsub /\D/, ''
    @zip = zip.to_s
    @city = city
    @state = state
    @address_line_1 = address_line_1
    @address_line_2 = address_line_2
    @holder_name = holder_name
  end

  # @return [Hash]
  def to_stripe
    {number: number,
     cvc: cvc,
     exp_month: expiry_month,
     exp_year: expiry_year,
     address_zip: zip,
     address_line1: address_line_1,
     address_line2: address_line_2,
     address_state: state,
     name: holder_name,
     address_city: city}
  end
end
