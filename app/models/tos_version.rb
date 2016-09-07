class TosVersion < ActiveRecord::Base
  has_many :tos_acceptances
  has_many :users, through: :tos_acceptances

  scope :published, -> { where.not(published_at: nil) }

  # @return [TosVersion, nil]
  def self.active
    published.where(active: true).first
  end

  # @return [Boolean]
  def published?
    published_at.present?
  end
end
