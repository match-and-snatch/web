FactoryGirl.define do
  factory :dialogue do
    before(:create) do |dialogue|
      users = dialogue.users

      if users.any?
        unless users.many?
          dialogue.users << FactoryGirl.create(:user)
        end
      else
        dialogue.users = [FactoryGirl.create(:user), FactoryGirl.create(:user)]
      end

      unless dialogue.recent_message
        dialogue.recent_message = FactoryGirl.create :message,
          dialogue: dialogue,
          user: dialogue.users.first,
          target_user: dialogue.users.last
        dialogue.recent_message_at = dialogue.recent_message.created_at
      end
    end
  end
end

