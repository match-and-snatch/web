class DialoguesUser < ApplicationRecord
  belongs_to :dialogue
  belongs_to :user
end