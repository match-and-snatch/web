class ProfileTypesUser < ActiveRecord::Base
  belongs_to :profile_type
  belongs_to :user
end