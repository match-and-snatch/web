class DialoguesUser < ActiveRecord::Base
  belongs_to :dialogue
  belongs_to :user
end