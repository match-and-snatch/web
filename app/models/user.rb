class User < ActiveRecord::Base
  has_many :offers, through: :user_offers
end