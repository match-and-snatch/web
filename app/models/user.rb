class User < ActiveRecord::Base
  include Concerns::Subscribable

  has_many :subscriptions
  has_many :source_subscriptions, class_name: 'Subscription', foreign_key: 'target_user_id'

  validates :slug, :email, presence: true

  # @see Concerns::Subscribable#subscription_source_user
  # @return [User]
  def subscription_source_user
    self
  end
end