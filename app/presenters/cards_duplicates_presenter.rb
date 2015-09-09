class CardsDuplicatesPresenter < DuplicatesPresenter

  # Returns users grouped by email
  # @return [Hash<String, Array<User>>]
  def collection
    @collection ||= users.group_by { |user| user.stripe_card_fingerprint }
  end

  private

  # Returns users with duplicate stripe_card_fingerprint
  # @return [Array<User>]
  def users
    User.where <<-SQL.squish
      stripe_card_fingerprint IN (
        SELECT stripe_card_fingerprint
        FROM users
        GROUP BY stripe_card_fingerprint
        HAVING COUNT(id) > 1)
    SQL
  end
end
