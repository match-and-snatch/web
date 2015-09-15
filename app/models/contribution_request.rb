class ContributionRequest < Request
  belongs_to :target_user, class_name: 'User'
end
