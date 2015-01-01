class User < ActiveRecord::Base
  has_many :offers
  has_many :favorites
  has_many :feedbacks
end