class Tag < ActiveRecord::Base
  has_many :offers_tags
  has_many :offers, through: :offers_tags
end