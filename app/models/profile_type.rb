class ProfileType < ActiveRecord::Base
  has_many :profile_types_users, dependent: :delete_all
  has_many :users, through: :profile_types_users
end