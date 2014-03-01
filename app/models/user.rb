class User < ActiveRecord::Base
  include Concerns::Subscribable

  has_many :subscriptions
  has_many :source_subscriptions, class_name: 'Subscription', foreign_key: 'target_user_id'

  validates :full_name, :email, presence: true
  before_create :generate_slug

  # @param new_password [String]
  def set_new_password(new_password)
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = generate_password_hash(new_password)
  end

  # @param some_password [String]
  # @return [String]
  def generate_password_hash(some_password)
    BCrypt::Engine.hash_secret(some_password, password_salt)
  end

  # @return [String]
  def first_name
    full_name.split(' ').first
  end

  # Checks if user has passed three steps of registration
  def complete_profile?
    [slug, subscription_cost, holder_name, routing_number, account_number].all?(&:present?)
  end

  # @see Concerns::Subscribable#subscription_source_user
  # @return [User]
  def subscription_source_user
    self
  end

  # Used for URL generation
  # @return [String]
  def to_param
    slug
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