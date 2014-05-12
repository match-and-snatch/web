class SetProfileTypeTextOnUsers < ActiveRecord::Migration
  def up
    User.find_each do |user|
      user.profile_types_text = user.profile_types.order(:ordering).map(&:title).join(', ')
      user.save!
    end
  end
end
