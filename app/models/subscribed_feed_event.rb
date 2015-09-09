class SubscribedFeedEvent < FeedEvent
  scope :by_users, -> (owner: , subscriber: ) { where(target_user_id: owner.id, target_id: subscriber.id).order(:created_at) }
end
