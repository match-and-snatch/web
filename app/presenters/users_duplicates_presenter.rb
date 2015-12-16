class UsersDuplicatesPresenter < DuplicatesPresenter

  # Returns users grouped by email
  # @return [Hash<String, Array<User>>]
  def collection
    @collection ||= users.group_by { |user| user.email.downcase }
  end

  # @return [Array<String>]
  def duplicates_values
    Kaminari.paginate_array(email_counts.keys.map(&:downcase)).page(page).per(per_page)
  end

  private

  # Returns counts per each duplicated email
  # @return [Hash<String, Integer>]
  def email_counts
    @email_counts ||= User.group('lower(users.email)').having('count(email) > 1').select('users.email').count
  end

  # Returns users with duplicate emails
  # @return [Array<User>]
  def users
    User.where(['lower(users.email) IN (?)', duplicates_values]).order('users.created_at')
  end
end

