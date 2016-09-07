class TosManager < BaseManager
  attr_reader :version

  # @param tos_version [TosVersion]
  def initialize(tos_version = nil)
    @version = tos_version
  end

  # @param tos [String]
  # @return [TosVersion]
  def create(tos: , privacy_policy: )
    fail_with! tos: :empty if tos.blank?
    fail_with! privacy_policy: :empty if privacy_policy.blank?

    @version = TosVersion.new(tos: tos, privacy_policy: privacy_policy)
    save_or_die! @version
  end

  # @param tos [String]
  # @return [TosVersion]
  def update(tos: , privacy_policy: )
    fail_with! tos: :empty if tos.blank?
    fail_with! privacy_policy: :empty if privacy_policy.blank?

    version.tos = tos
    version.privacy_policy = privacy_policy
    save_or_die! version
  end

  # To activate version you need to publish it
  # Latest published version becomes active
  # Only active version will be displayed to users
  def publish
    fail_with! 'Already published' if version.published?

    version.published_at = Time.zone.now
    version.active = true

    ActiveRecord::Base.transaction do
      save_or_die! version
      TosVersion.where.not(id: version.id).update_all(active: false)
    end

    reset_tos_acceptance
  end

  def reset_tos_acceptance
    ActiveRecord::Base.transaction do
      TosAcceptance.active.delete_all
      User.where(tos_accepted: true).update_all(tos_accepted: false)
    end
  end

  def toggle_acceptance_requirement
    version.requires_acceptance = !version.requires_acceptance
    save_or_die! version
  end
end
