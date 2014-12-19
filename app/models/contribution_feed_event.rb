class ContributionFeedEvent < FeedEvent

  # @return [Contribution]
  def contribution
    target
  end

  def data
    super.tap do |result|
      result[:amount] ||= (contribution.amount / 100).to_i
      if result[:recurring].nil?
        result[:recurring] = contribution.recurring?
      end
      result[:type] ||= result[:recurring] ? 'monthly recurring' : 'one-time'
    end
  end
end