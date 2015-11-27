class User < ActiveRecord::Base
  FAKE_TOKEN = 'fake'.freeze
  ROLE_FIELDS = {is_admin: 'admin', is_sales: 'sales'}.freeze

  include Concerns::Subscribable
  include Elasticpal::Indexable

  serialize :contacts_info, Hash

  belongs_to :last_visited_profile, class_name: 'User'
  belongs_to :partner, class_name: 'User'

  has_many :contributions
  has_many :source_contributions, class_name: 'Contribution', foreign_key: 'target_user_id'
  has_many :benefits
  has_many :posts
  has_many :comments
  has_many :credit_card_declines
  has_many :subscriptions
  has_many :source_subscriptions, class_name: 'Subscription', foreign_key: 'target_user_id'
  has_many :uploads, as: :uploadable
  has_many :source_uploads, class_name: 'Upload'
  has_many :likes
  has_many :source_likes, class_name: 'Like', foreign_key: 'target_user_id'
  has_many :pending_post_uploads, -> { pending.ordered.posts }, class_name: 'Upload'
  has_many :pending_video_preview_photos, -> { pending.ordered }, class_name: 'PendingVideoPreviewPhoto'
  has_many :profile_types_users
  has_many :profile_types, through: :profile_types_users
  has_many :payments
  has_many :payment_failures
  has_many :source_payments, class_name: 'Payment', foreign_key: 'target_user_id'
  has_many :dialogues_users
  has_many :dialogues, through: :dialogues_users do
    def not_removed
      where(dialogues_users: {removed: false})
    end
  end
  has_many :messages
  has_many :events
  has_many :cost_change_requests
  has_many :delete_profile_page_requests
  has_many :contribution_requests
  has_many :credit_card_update_requests
  has_many :subscription_daily_count_change_events
  has_many :subordinates, class_name: 'User', foreign_key: 'partner_id'

  has_one :top_profile
  has_one :pending_post
  has_one :profile_page

  validates :full_name, :email, presence: true
  before_create :generate_slug, if: :is_profile_owner? # TODO: move to manager
  before_save :set_profile_completion_status, if: :is_profile_owner?

  scope :admins, -> { where(is_admin: true) }
  scope :staff, -> { where(ROLE_FIELDS.keys.map { |r| "users.#{r} = 't'" }.join(' OR ')) }
  scope :profile_owners, -> { where(is_profile_owner: true) }
  scope :subscribers, -> { where(is_profile_owner: false) }
  scope :with_complete_profile, -> { where(has_complete_profile: true) }
  scope :by_email, -> (email) { where(['email ILIKE ?', email]) }
  scope :top, -> { profile_owners.joins(:top_profile).order('top_profiles.position') }
  scope :mentions, -> (current_user: , query: , profile_id: nil) {
    where.not(id: current_user.id).search_by_text_fields(query).limit(5).tap do |users|
      if profile_id
        if current_user.id == profile_id.to_i
          users.merge! users.joins(:subscriptions).where(subscriptions: {target_user_id: profile_id})
        else
          users.merge! users.joins("LEFT OUTER JOIN subscriptions ON subscriptions.user_id = users.id")
                            .where(["subscriptions.target_user_id = ? OR users.id = ?", profile_id, profile_id])
                            .group("users.id, pg_search.rank")
        end
      end
    end
  }

  elastic_type do
    field :full_name, :profile_name
  end

  elastic_type 'profiles' do
    field :full_name, :profile_name, :profile_types_text
    field :subscribers_count # used for boosting results
    field :publicly_visible?
  end

  def self.random_public_profile
    where(has_public_profile: true).order("random()").first
  end

  def self.fake
    fake_user = User.where(registration_token: FAKE_TOKEN).first
    return fake_user if fake_user

    User.create! :account_number => nil,
                 :activated => true,
                 :email => 'fake@connectpal.com',
                 :full_name => 'Fake User',
                 :has_complete_profile => false,
                 :has_public_profile => false,
                 :hidden => true,
                 :holder_name => 'Fake User',
                 :is_admin => false,
                 :is_profile_owner => false,
                 :profile_name => 'Fake User',
                 :registration_token => FAKE_TOKEN,
                 :subscribers_count => 0,
                 :subscription_cost => 0,
                 :subscription_fees => 0
  end

  ROLE_FIELDS.each do |field, val|
    name = "#{val.parameterize('_')}?"

    define_method name do
      public_send(field) || admin?
    end
  end

  def admin?
    is_admin? || APP_CONFIG['admins'].include?(email.try(:downcase))
  end

  def roles
    [].tap do |result|
      ROLE_FIELDS.values.each do |role|
        result << role if public_send("#{role.parameterize('_')}?")
      end
    end
  end

  def staff?
    roles.any?
  end

  def publicly_visible?
    is_profile_owner? && has_complete_profile? &&
      (subscribers_count > 0 || profile_picture_url.present?) &&
        !(hidden? || has_mature_content?)
  end

  def cc_decline
    decline = credit_card_declines.first
    return decline if decline

    if stripe_card_fingerprint.present?
      CreditCardDecline.where(stripe_fingerprint: stripe_card_fingerprint).first
    end
  end

  def cc_declined?
    if stripe_card_fingerprint.present?
      CreditCardDecline.where(stripe_fingerprint: stripe_card_fingerprint).any?
    else
      credit_card_declines.any?
    end
  end

  def lock!(reason = 'account')
    self.lock_reason = reason
    self.locked = true
    self.last_time_locked_at = Time.zone.now
    save!
  end

  def unlock!
    raise ArgumentError unless locked?
    self.locked = false
    save!
  end

  def cost_approved?
    cost_change_requests.new_large_cost.pending.empty?
  end

  def comment_picture_url
    small_account_picture_url || small_profile_picture_url
  end

  def custom_profile_page_css
    profile_page_data.css
  end

  def denormalize_last_post_created_at!(time = nil)
    if time
      update!(last_post_created_at: time)
    else
      update!(last_post_created_at: posts.where(hidden: false).maximum(:created_at))
    end
  end

  # @param new_password [String]
  def set_new_password(new_password)
    self.password_hash = BCrypt::Password.create(new_password)
  end

  def generate_api_token!
    return if api_token.present?
    regenerate_api_token!
  end

  def regenerate_api_token!
    self.api_token = SecureRandom.uuid.gsub(/\-/,'')
    save!
  end

  # @return [String]
  def first_name
    full_name.split(' ').first if full_name
  end

  def has_profile_page?
    has_complete_profile? && is_profile_owner?
  end

  def complete_profile?
    read_attribute(:has_complete_profile) || profile_enabled?
  end

  # Checks if profile owner hasn't passed three steps of registration
  def profile_disabled?
    is_profile_owner? && !passed_profile_steps?
  end

  def profile_enabled?
    is_profile_owner? && passed_profile_steps?
  end

  def profile_page_data
    @profile_page_data ||= ProfilePageDataProxy.new(self)
  end

  # Checks if a user hasn't passed three steps of registration
  def passed_profile_steps?
    # [slug, subscription_cost, holder_name, routing_number, account_number].all?(&:present?)
    [profile_name, slug, cost].all?(&:present?)
  end

  # Checks if user filled all the necessary information
  def has_full_account?
    [slug, subscription_cost, holder_name, routing_number, account_number].all?(&:present?)
  end

  # Returns true if user has passed Stripe registration
  def has_cc_payment_account?
    [last_four_cc_numbers, stripe_card_id, stripe_user_id].all?(&:present?)
  end

  def subscribed_to?(target)
    return false unless target
    return false if new_record?

    subscription = subscriptions.by_target(target).first

    return false unless subscription

    active = !(subscription.removed? && subscription.expired?)
    paid = subscription.processing_payment? || !subscription.rejected?

    paid && active
  end

  def recently_subscribed?
    !!recent_subscription_at && recent_subscription_at > 48.hours.ago
  end

  def subscribers
    User.joins(:subscriptions).where(subscriptions: {target_user_id: id, removed: false})
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

  # @return [String]
  def name
    if is_profile_owner
      profile_name || full_name || holder_name || email
    else
      full_name || holder_name || profile_name || email
    end
  end

  # @return [String]
  def sample_slug
    @slug_example ||= begin
      slug_base = (profile_name || full_name).parameterize.gsub('-', '')
      slug = slug_base
      i = 0

      while User.where(slug: slug).where.not(id: id).any?
        slug = "#{slug_base}-#{i+=1}"
      end

      slug
    end
  end

  def generate_slug
    unless slug.present?
      self.slug = sample_slug
    end

    true
  end

  def generate_auth_token
    begin
      self.auth_token = SecureRandom.urlsafe_base64
    end while User.exists?(auth_token: self.auth_token)
    true
  end

  def generate_registration_token
    begin
      self.registration_token = SecureRandom.urlsafe_base64
    end while User.exists?(registration_token: self.registration_token)
    true
  end

  def generate_password_reset_token!
    self.password_reset_token = SecureRandom.urlsafe_base64
    self.save!
  end

  # Sets costs and fees
  # Logic:
  # $4 or less = $0.99
  # $5 - $15 = $1.99
  # $16 and above = 15% of subscription price
  #
  # @param val [Integer]
  # @return [S]
  def cost=(val)
    super(val).tap do |cost|
      cost = cost.to_i
      fees = 0

      if cost <= 4_00
        fees = 99
      elsif cost >= 5_00 && cost <= 15_00
        fees = 1_99
      elsif cost >= 16_00
        fees = cost / 100 * 15
      else
        raise ArgumentError, 'Invalid cost'
      end

      self.subscription_fees = fees
      self.subscription_cost = fees + cost
    end
  end

  def pretend(attrs = {})
    self.dup.tap do |user|
      attrs.each do |key, val|
        user.send("#{key}=", val)
      end
    end
  end

  def profile_types_text
    profile_types.map(&:title).join(', ')
  end

  def created_profile_page?
    !((!passed_profile_steps? && is_profile_owner?) || (!is_profile_owner?))
  end

  def contributions_allowed?
    contributions_enabled? && subscribers_count > 4
  end

  def bank_account_data
    {
      country: 'US',
      routing_number: routing_number,
      account_number: account_number,
    }
  end

  def unread_messages_count
    dialogues.not_removed.unread.joins(:recent_message).where.not(messages: {user_id: id}).count
  end

  # @param attributes [Hash]
  # @return [ProfilePage]
  def update_profile_page!(attributes)
    profile_page_data.update!(attributes)
  end

  # @return [Video, nil]
  def welcome_video
    Video.users.where(uploadable_id: id).order('created_at DESC').first
  end

  # @return [Audio, nil]
  def welcome_audio
    Audio.users.where(uploadable_id: id).order('created_at DESC').first
  end

  private

  def set_profile_completion_status
    self.has_complete_profile = true if complete_profile?
    true
  end
end
