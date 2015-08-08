class Event < ActiveRecord::Base
  serialize :data, Hash

  belongs_to :user
  belongs_to :subject, polymorphic: true

  scope :daily, -> { where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day) }
end
