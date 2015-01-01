class User < ActiveRecord::Base
  has_many :offers
  has_many :favorites
  has_many :feedbacks
  has_many :subscriptions
  has_many :messages
end