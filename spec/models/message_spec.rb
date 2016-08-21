describe Message do
  let(:user) { create(:user) }
  let(:target_user) { create(:user) }
  let(:message) { create :message, user: user, target_user: target_user }
end
