module Concerns::Payable

  # @return [Integer] Amount in cents
  def cost
    raise NotImplementedError
  end

  # @return [User]
  def customer
    raise NotImplementedError
  end
end
