class User < ActiveRecord::Base
  include PgSearch
  include Concerns::Subscribable

  has_many :benefits
  has_many :posts
  has_many :comments
  has_many :subscriptions
  has_many :source_subscriptions, class_name: 'Subscription', foreign_key: 'target_user_id'
  has_many :uploads, as: :uploadable

  validates :full_name, :email, presence: true
  before_create :generate_slug, if: :is_profile_owner?

  scope :profile_owners, -> { where(is_profile_owner: true) }
  scope :subscribers, -> { where(is_profile_owner: false) }

  pg_search_scope :search_by_full_name, against: :full_name,
                                        using: [:tsearch, :dmetaphone, :trigram],
                                        ignoring: :accents

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
    full_name.split(' ').first if full_name
  end

  # Checks if profile owner hasn't passed three steps of registration
  def has_incomplete_profile?
    is_profile_owner? && [slug, subscription_cost, holder_name, routing_number, account_number].all?(&:present?)
  end

  # Returns true if user has passed Stripe registration
  def has_cc_payment_account?
    [last_four_cc_numbers, stripe_card_id, stripe_user_id].all?(&:present?)
  end

  def subscribed_to?(target)
    subscriptions.by_target(target).any?
  end

  # @see Concerns::Subscribable#subscription_source_user
  # @return [User]
  def subscription_source_user
    self
  end

  # Used for URL generation
  # @return [String]
  def to_param
    slug || id.to_s
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
