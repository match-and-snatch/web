module Concerns::Payable
  extend ActiveSupport::Concern

  DEFAULT_BILLING_CYCLE_LENGTH = 30.days

  # @return [ActiveSupport::Duration]
  def self.billing_cycle_length
    cdate = Date.current

    # Handle last date of February
    if cdate.month == 2 && cdate.end_of_month == cdate
      cdate.day.days
    else
      DEFAULT_BILLING_CYCLE_LENGTH
    end
  end

  # Returns past matching billing date to current date
  # @return [Date]
  def self.billing_edge_date
    Time.zone.now.end_of_day - billing_cycle_length
  end

  included do
    scope :on_charge, -> {
      cmonth = Date.current.month

      where(['charged_at <= ? OR charged_at IS NULL', billing_edge_date])
        .joins(:target_user)
        .where(users: {is_profile_owner: true})
        .readonly(false)
    }
  end

  # @return [User]
  def customer
    raise NotImplementedError
  end

  # @return [Boolean]
  def payable?
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

  def billing_cycle_length
    self.class.billing_cycle_length
  end

  def billing_edge_date
    self.class.billing_edge_date
  end

  module ClassMethods
    def billing_cycle_length
      Concerns::Payable.billing_cycle_length
    end

    def billing_edge_date
      Concerns::Payable.billing_edge_date
    end
  end
end
