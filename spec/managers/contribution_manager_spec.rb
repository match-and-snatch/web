require 'spec_helper'

describe ContributionManager do
  subject(:manager) { ContributionManager.new(user: user, contribution: contribution) }
  let(:contribution) { nil }

  let(:user) { create :user }
  let(:target_user) { create :user, :profile_owner }

  before { StripeMock.start }
  after { StripeMock.stop }

  before do
    5.times do |i|
      SubscriptionManager.new(subscriber: create(:user, email: "subscriber_#{i}@test.com")).subscribe_to(target_user)
    end
  end

  describe '#create' do
    it 'creates new contribution' do
      expect { manager.create(amount: 1, target_user: target_user) }.to create_record(Contribution)
    end

    it 'creates a message' do
      expect { manager.create(amount: 1, target_user: target_user) }.to create_record(Message).matching(message: 'Contribution')
    end

    it 'sends email about contribution to target user' do
      expect { manager.create(amount: 1, target_user: target_user) }.to deliver_email(to: target_user, subject: /You have received a contribution/)
    end

    it 'sends email about contribution to contributor' do
      expect { manager.create(amount: 1, target_user: target_user) }.to deliver_email(to: user, subject: /You have successfully made a contribution/)
    end

    it 'sets amount' do
      expect(manager.create(amount: 1, target_user: target_user).amount).to eq(1)
    end

    it 'sets recurring' do
      expect(manager.create(amount: 1, target_user: target_user, recurring: true).recurring).to eq(true)
    end

    it 'creates events' do
       expect { manager.create(amount: 1, target_user: target_user) }.to create_event(:contribution_created)
    end

    it 'logs gross contributions' do
      expect { manager.create(amount: 1, target_user: target_user) }.to change { target_user.gross_contributions }.from(0).to(1)
    end

    it 'creates message' do
      expect { manager.create(amount: 1, target_user: target_user, message: 'test') }.to change { Message.count }.by(1)
    end

    context 'target user blocked with ToS type' do
      before { UserManager.new(target_user).lock(type: :tos) }

      it 'does not send email about contribution to target user' do
        expect { manager.create(amount: 1, target_user: target_user) rescue nil }.not_to deliver_email(to: target_user, subject: /You have received a contribution/)
      end
    end

    context 'zero amount' do
      it do
        expect { manager.create(amount: 0, target_user: target_user) }.to raise_error(ManagerError, /zero/)
      end

      it do
        expect { manager.create(amount: nil, target_user: target_user) }.to raise_error(ManagerError, /zero/)
      end
    end

    context 'multiple contributions to different profiles' do
      let(:target_user) { create(:user, :profile_owner, contributions_enabled: true, subscribers_count: 5) }
      let(:amount) { 24_00 }

      before do
        ContributionManager.new(user: user).create(amount: amount, target_user: target_user)
        Timecop.travel(1.day.since) do
          ContributionManager.new(user: user).create(amount: amount, target_user: target_user)
        end

        Timecop.travel(2.days.since) do
          ContributionManager.new(user: user).create(amount: amount, target_user: target_user)
        end

        Timecop.travel(3.days.since) do
          ContributionManager.new(user: user).create(amount: amount, target_user: target_user)
        end
      end

      context '$120 in 1 week' do
        specify do
          Timecop.travel(4.days.since) do
            expect { ContributionManager.new(user: user).create(amount: amount, target_user: target_user) }.to change { user.reload.locked? }.to(true)
          end
        end

        specify do
          Timecop.travel(4.days.since) do
            expect { ContributionManager.new(user: user).create(amount: amount, target_user: target_user) }.to change { user.reload.lock_type }.to('billing')
          end
        end

        specify do
          Timecop.travel(4.days.since) do
            expect { ContributionManager.new(user: user).create(amount: amount, target_user: target_user) }.to change { user.reload.lock_reason }.to('contribution_limit')
          end
        end

        context 'unlocked after lock' do
          before do
            Timecop.travel(4.days.since) do
              ContributionManager.new(user: user).create(amount: amount, target_user: target_user)
            end
            UserManager.new(user).unlock
          end

          specify do
            Timecop.travel(5.days.since) do
              expect { ContributionManager.new(user: user).create(amount: amount, target_user: target_user) }.not_to change { user.reload.locked? }.from(false)
            end
          end
        end
      end

      context '$250 in 1 week if accepts large contributions' do
        let(:target_user) { create(:user, :profile_owner, contributions_enabled: true, accepts_large_contributions: true, subscribers_count: 5) }
        let(:amount) { 50_00 }

        specify do
          Timecop.travel(4.days.since) do
            expect { ContributionManager.new(user: user).create(amount: amount, target_user: target_user) }.to change { user.reload.locked? }.to(true)
          end
        end

        specify do
          Timecop.travel(4.days.since) do
            expect { ContributionManager.new(user: user).create(amount: amount, target_user: target_user) }.to change { user.reload.lock_type }.to('billing')
          end
        end

        specify do
          Timecop.travel(4.days.since) do
            expect { ContributionManager.new(user: user).create(amount: amount, target_user: target_user) }.to change { user.reload.lock_reason }.to('contribution_limit')
          end
        end
      end
    end

    context 'huge contribution' do
      context 'too huge' do
        it { expect { manager.create(amount: 1000_000_000_000_000_000_00, target_user: target_user) }.to raise_error(ManagerError, /large/) }
      end

      it 'has $100 limit' do
        expect { manager.create(amount: 100_01, target_user: target_user) rescue nil }.not_to create_record(Contribution)
      end

      it 'creates contribution request' do
        expect { manager.create(amount: 100_01, target_user: target_user) rescue nil }.to create_record(ContributionRequest).matching(user: user, target_user: target_user, amount: 100_01)
      end

      it do
        expect { manager.create(amount: 100_01, target_user: target_user) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(amount: t_error(:contribution_limit_reached)) }
      end

      context 'verified profile owner' do
        before { UserProfileManager.new(target_user).toggle_accepting_large_contributions; target_user.reload }

        it 'allows contributing up to 1000$' do
          expect { manager.create(amount: 1000_00, target_user: target_user) }.to create_record(Contribution).matching(amount: 1000_00, user: user, target_user: target_user)
        end

        it 'does not allow contributing more than 1000$' do
          expect { manager.create(amount: 1000_01, target_user: target_user) rescue nil }.not_to create_record(Contribution)
        end

        context 'multiple contributions' do
          before do
            manager.create(amount: 100_00, target_user: target_user)
          end

          it 'allows contributing up to 1000$' do
            Timecop.freeze(8.days.from_now) do
              expect { manager.create(amount: 900_00, target_user: target_user) }.to create_record(Contribution).matching(amount: 900_00, user: user, target_user: target_user)
            end
          end

          it 'does not allow contributing more than 1000$' do
            expect { manager.create(amount: 900_01, target_user: target_user) rescue nil }.not_to create_record(Contribution)
          end
        end
      end

      context 'multiple contributions' do
        before do
          manager.create(amount: 25_00, target_user: target_user)
        end

        it 'has $30 limit' do
          expect { manager.create(amount: 25_01, target_user: target_user) rescue nil }.not_to create_record(Contribution)
        end

        it do
          expect { manager.create(amount: 25_01, target_user: target_user) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(amount: t_error(:contribution_limit_reached)) }
        end

        context 'to multiple profiles' do
          let(:another_target_user) { create(:user, :profile_owner, email: 'another_target@gmail.com') }

          before do
            5.times do |i|
              SubscriptionManager.new(subscriber: create(:user, email: "another_subscriber_#{i}@test.com")).subscribe_to(another_target_user)
            end
          end

          it do
            expect { manager.create(amount: 25_01, target_user: another_target_user) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(amount: t_error(:contribution_limit_reached)) }
          end
        end

        context 'made with 24 hours interval' do
          it 'resets daily limit' do
            Timecop.travel 24.hours.since do
              expect { manager.create(amount: 30_00, target_user: target_user) }.to create_record(Contribution).matching(user: user, target_user: target_user, amount: 30_00)
            end
          end
        end
      end

      context 'with pending contribution request' do
        before { user.contribution_requests.create!(target_user: target_user, amount: 100_01) }

        context 'to the same user' do
          it do
            expect { manager.create(amount: 100_01, target_user: target_user) rescue nil }.not_to create_record(Contribution)
          end
          it do
            expect { manager.create(amount: 100_01, target_user: target_user) rescue nil }.not_to create_record(ContributionRequest)
          end
          it do
            expect { manager.create(amount: 100_01, target_user: target_user) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(amount: t_error(:contribution_limit_reached)) }
          end
        end

        context 'to different user' do
          let(:another_target_user) { create(:user, :profile_owner, email: 'another_target@gmail.com') }

          before do
            5.times do |i|
              SubscriptionManager.new(subscriber: create(:user, email: "another_subscriber_#{i}@test.com")).subscribe_to(another_target_user)
            end
          end

          it do
            expect { manager.create(amount: 100_01, target_user: another_target_user) rescue nil }.not_to create_record(Contribution)
          end
          it do
            expect { manager.create(amount: 100_01, target_user: another_target_user) rescue nil }.to create_record(ContributionRequest)
          end
          it do
            expect { manager.create(amount: 100_01, target_user: another_target_user) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(amount: t_error(:contribution_limit_reached)) }
          end
        end
      end

      context 'with approved contribution request' do
        let(:request) { user.contribution_requests.create!(target_user: target_user, amount: 50_01) }

        before { ContributionManager.new(user: user).approve!(request) }

        it do
          expect { manager.create(amount: 50_01, target_user: target_user) rescue nil }.to create_record(Contribution)
        end

        it 'has $120 limit' do
          expect { another_manager.create(amount: 120_01, target_user: target_user) rescue nil }.not_to create_record(Contribution)
        end

        it do
          expect { manager.create(amount: 120_01, target_user: target_user) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(amount: t_error(:contribution_limit_reached)) }
        end
      end
    end

    context 'charge fails' do
      before do
        StripeMock.prepare_card_error(:card_declined)
      end

      it 'does not create event about new contribution' do
        expect { manager.create(amount: 1, target_user: target_user) rescue nil }.not_to create_event(:contribution_created)
      end

      it 'does not log gross contributions' do
        expect { manager.create(amount: 1, target_user: target_user) rescue nil }.not_to change { target_user.gross_contributions }.from(0)
      end

      it do
        expect { manager.create(amount: 1, target_user: target_user) rescue nil }.to create_event(:contribution_failed)
      end

      it do
        expect { manager.create(amount: 1, target_user: target_user) rescue nil }.not_to create_record(Contribution)
      end

      it 'does not create message' do
        expect { manager.create(amount: 1, target_user: target_user, message: 'test') rescue nil }.not_to create_record(Message)
      end
    end

    context 'with less then 5 subscribers' do
      let(:another_target_user) { create(:user, :profile_owner, email: 'another_target@gmail.com') }

      it { expect { manager.create(amount: 1, target_user: another_target_user) rescue nil }.not_to create_record(Contribution) }
      it { expect { manager.create(amount: 1, target_user: another_target_user) }.to raise_error(ManagerError, /You can't contribute to this profile/) }
    end
  end

  describe '#create' do
    let!(:contribution) { described_class.new(user: user).create(amount: 1, target_user: target_user, recurring: true) }

    it 'creates new contribution' do
      expect(manager.create_child).to be_a(Contribution)
    end

    it do
      expect(manager.create_child).not_to be_a_new_record
    end

    it do
      expect { manager.create_child }.to create_record(Contribution).matching(amount: 1 , target_user: target_user, recurring: false)
    end

    it 'sets amount' do
      expect(manager.create_child.amount).to eq(1)
    end

    it 'sets recurring' do
      expect(manager.create_child.recurring).to eq(false)
    end

    it 'creates events' do
       expect { manager.create_child }.to create_event(:contribution_created)
    end

    it 'logs gross contributions' do
      expect { manager.create_child }.to change { target_user.gross_contributions }.from(1).to(2)
    end

    context 'charge fails' do
      before do
        StripeMock.prepare_card_error(:card_declined)
      end

      it 'does not create event about new contribution' do
        expect { manager.create_child rescue nil }.not_to create_event(:contribution_created)
      end

      it 'does not log gross contributions' do
        expect { manager.create_child }.not_to change { target_user.gross_contributions }.from(1)
      end

      it do
        expect { manager.create_child rescue nil }.to create_event(:contribution_failed)
      end

      it do
        expect { manager.create_child rescue nil }.not_to create_record(Contribution)
      end

      it do
        expect(manager.create_child).to be_a(Contribution)
      end

      it do
        expect(manager.create_child.new_record?).to eq(true)
      end
    end
  end

  describe '#approve!' do
    let(:request) { user.contribution_requests.create!(target_user: target_user, amount: 100_01) }

    it 'creates contribution' do
      expect { manager.approve!(request) }.to create_record(Contribution).matching(user: user, target_user: target_user, amount: 100_01)
    end

    it 'approves request' do
      expect { manager.approve!(request) }.to change { request.approved? }.from(false).to(true)
    end

    it 'performs request' do
      expect { manager.approve!(request) }.to change { request.performed? }.from(false).to(true)
    end
  end
end
