class ProfileTypesUser < ApplicationRecord
  belongs_to :profile_type
  belongs_to :user

  before_save do
    self.ordering = user.profile_types.count
  end
end
