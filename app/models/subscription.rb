class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :offer
  has_many :subscriptions_tags
  has_many :tags, through: :subscriptions_tags
end