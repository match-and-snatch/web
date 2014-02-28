class User < ActiveRecord::Base
  include Concerns::Subscribable

  has_many :subscriptions
  has_many :source_subscriptions, class_name: 'Subscription', foreign_key: 'target_user_id'

  validates :full_name, :email, presence: true
  before_create :generate_slug

  # @see Concerns::Subscribable#subscription_source_user
  # @return [User]
  def subscription_source_user
    self
  end

  private

  def generate_slug
    slug_base = full_name.parameterize
    slug = slug_base
    i = 0

    while User.where(slug: slug).any?
      slug = "#{slug_base}-#{i+=1}"
    end

    self.slug = slug
    true
  end
end