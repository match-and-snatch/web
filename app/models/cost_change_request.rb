class CostChangeRequest < Request

  def approve!(update_existing_costs: nil)
    unless update_existing_costs.nil?
      self.update_existing_subscriptions = update_existing_costs
    end

    self.approved = true
    self.approved_at = Time.zone.now
    self.save!
  end
end
