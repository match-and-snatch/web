class ContributionRequest < Request
  belongs_to :target_user, class_name: 'User'

  scope :by_target_user, -> (target_user) { where(target_user_id: target_user.id) }
end
