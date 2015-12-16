class CardsDuplicatesPresenter < DuplicatesPresenter

  # Returns users grouped by email
  # @return [Hash<String, Array<User>>]
  def collection
    @collection ||= users.group_by { |user| user.stripe_card_fingerprint }
  end

  # @return [Array<String>]
  def duplicates_values
    User.group(:stripe_card_fingerprint).having('COUNT(id) > 1').select(:stripe_card_fingerprint).page(page).per(per_page)
  end

  private

  # Returns users with duplicate stripe_card_fingerprint
  # @return [Array<User>]
  def users
    User.where(stripe_card_fingerprint: duplicates_values).order(created_at: :desc)
  end
end
