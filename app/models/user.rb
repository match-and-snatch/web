class User < ActiveRecord::Base
  has_many :offers
  has_many :favorites
end