class Event < ApplicationRecord
  belongs_to :user, autosave: false
  belongs_to :subject, polymorphic: true, autosave: false

  def self.base_scope
    where(subject_deleted: false)
  end

  scope :daily, -> { where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day) }
end
