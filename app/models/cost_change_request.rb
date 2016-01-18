class CostChangeRequest < Request
  MAX_COST = 11_00

  scope :new_large_cost, -> { where("old_cost IS NULL AND new_cost >= ?", MAX_COST) }

  def approve!(update_existing_costs: nil)
    unless update_existing_costs.nil?
      self.update_existing_subscriptions = update_existing_costs
    end

    self.approved = true
    self.approved_at = Time.zone.now
    self.save!
  end

  def initial?
    old_cost.nil?
  end

  def completes_profile?
    initial? && user.passed_profile_steps?
  end
end
