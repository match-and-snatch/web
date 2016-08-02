class TosManager < BaseManager
  attr_reader :version

  # @param tos_version [TosVersion]
  def initialize(tos_version = nil)
    @version = tos_version
  end

  # @param tos [String]
  # @return [TosVersion]
  def create(tos: )
    fail_with! tos: :empty if tos.blank?

    @version = TosVersion.new(tos: tos)
    save_or_die! @version
  end

  # To activate version you need to publish it
  # Latest published version becomes active
  # Only active version will be displayed to users
  def publish
    fail_with! 'Already published' if version.published?

    version.published_at = Time.zone.now
    save_or_die! version
  end

  # @param tos [String]
  def reset_tos_acceptance(tos: )
    create(tos: tos)
    publish
    User.update_all(tos_accepted: false)
  end
end
