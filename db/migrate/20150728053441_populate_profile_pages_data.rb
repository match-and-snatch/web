class PopulateProfilePagesData < ActiveRecord::Migration
  def change
    User.where('custom_profile_page_css is not null').find_each do |user|
      ProfilePage.create!(user: user, css: user.custom_profile_page_css)
      user.update!(has_custom_profile_page_css: true)
    end
  end
end
