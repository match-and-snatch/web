class User < ActiveRecord::Base
  validates :slug, :email, presence: true
end