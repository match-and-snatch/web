class CommentIgnore < ApplicationRecord
  belongs_to :user
  belongs_to :commenter, class_name: 'User'

  scope :by_commenter, -> (commenter) { where(commenter_id: commenter.id) }
end
