module Concerns::Payable
  extend ActiveSupport::Concern

  included do
    scope :on_charge, -> { where(['charged_at <= ? OR charged_at IS NULL', 1.month.ago]).joins(:target_user).where(users: { is_profile_owner: true }).readonly(false) }
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
