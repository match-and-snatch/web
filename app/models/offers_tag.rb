class OffersTag < ActiveRecord::Base
  belongs_to :offer
  belongs_to :tag
end