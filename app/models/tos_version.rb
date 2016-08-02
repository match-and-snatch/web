class TosVersion < ActiveRecord::Base
  has_many :tos_acceptances
  has_many :users, through: :tos_acceptances

  scope :published, -> { where.not(published_at: nil) }

  # @return [TosVersion, nil]
  def self.active
    published.order(published_at: :desc).first
  end

  # @return [Boolean]
  def active?
    self == self.class.active
  end

  # @return [Boolean]
  def published?
    published_at.present?
  end
end
