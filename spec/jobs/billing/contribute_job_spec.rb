describe Billing::ContributeJob do
  subject(:perform) { described_class.new.perform }

  let(:user) { create :user }
  let(:target_user) { create :user, :profile_owner }

  before { StripeMock.start }
  after { StripeMock.stop }

  before do
    Timecop.freeze(32.days.ago) do
      5.times do |i|
        SubscriptionManager.new(subscriber: create(:user, email: "subscriber_#{i}@test.com")).subscribe_to(target_user)
      end

      SubscriptionManager.new(subscriber: user).subscribe_to(target_user)
      ContributionManager.new(user: user).create(amount: 10, target_user: target_user, recurring: true)
    end
  end

  it { expect { perform }.to deliver_email(to: APP_CONFIG['emails']['reports'], subject: /Contribute Job/) }
  it { expect { perform }.to create_record(Contribution).matching(amount: 10 , target_user: target_user, recurring: false) }

  it 'logs gross contributions' do
    expect { perform }.to change { target_user.reload.gross_contributions }.from(10).to(20)
  end

  context 'user is locked' do
    before { UserManager.new(user).lock }

    it { expect { perform }.not_to create_record(Contribution) }
  end

  context 'target user does not accept contributions' do
    context 'target user is locked' do
      before { UserManager.new(target_user).lock }

      it { expect { perform }.not_to create_record(Contribution) }
    end

    context 'contributions disabled' do
      before { UserProfileManager.new(target_user).disable_contributions }

      it { expect { perform }.not_to create_record(Contribution) }
    end
  end
end
