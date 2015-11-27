FactoryGirl.define do
  factory :message do
    message 'Test message'

    before(:create) do |message|
      unless message.dialogue
        message.dialogue = FactoryGirl.create :dialogue,
          recent_message: message,
          users: [message.user, message.target_user].compact
      end
    end
  end
end
