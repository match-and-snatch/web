class Refund < ApplicationRecord
  serialize :metadata, Hash

  belongs_to :payment
  belongs_to :user
end
