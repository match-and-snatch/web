module Concerns::Payable
  extend ActiveSupport::Concern

  included do
    scope :on_charge, -> { where(['charged_at <= ?', 1.month.ago]) }
  end

  # @return [Integer] Amount in cents
  def cost
    raise NotImplementedError
  end

  # @return [User]
  def customer
    raise NotImplementedError
  end

  # @return [User]
  def recipient
    raise NotImplementedError
  end

  # @return [String]
  def statement_description
    raise NotImplementedError
  end
end
