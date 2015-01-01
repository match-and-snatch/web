class Offer < ActiveRecord::Base
  belongs_to :user
  has_many :favorites
  has_many :offers_tags
  has_many :tags, through: :offers_tags
end