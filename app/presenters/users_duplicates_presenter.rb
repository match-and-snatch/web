class UsersDuplicatesPresenter < DuplicatesPresenter

  # Returns users grouped by email
  # @return [Hash<String, Array<User>>]
  def collection
    @collection ||= users.group_by { |user| user.email.downcase }
  end

  private

  # @return [Array<String>]
  def duplicate_emails
    email_counts.keys.map(&:downcase)
  end

  # Returns counts per each duplicated email
  # @return [Hash<String, Integer>]
  def email_counts
    @email_counts ||= User.group('lower(users.email)').having('count(email) > 1').select('users.email').count
  end

  # Returns users with duplicate emails
  # @return [Array<User>]
  def users
    User.where(['lower(users.email) IN (?)', duplicate_emails]).order('users.created_at')
  end
end

