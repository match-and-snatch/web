class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :offer
  belongs_to :parent, class_name: 'Message'
end