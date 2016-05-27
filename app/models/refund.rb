class Refund < ActiveRecord::Base
  serialize :metadata, Hash

  belongs_to :payment
  belongs_to :user
end
