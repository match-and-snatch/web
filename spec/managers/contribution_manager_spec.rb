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
      SubscriptionManager.new(subscriber: create_user(email: "subscriber_#{i}@test.com")).subscribe_to(target_user)
    end
  end

  describe '#create' do
    it 'creates new contribution' do
      expect { manager.create(amount: 1, target_user: target_user) }.to create_record(Contribution)
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
       expect { manager.create(amount: 1, target_user: target_user)  }.to create_event(:contribution_created)
    end

    it 'creates message' do
      expect { manager.create(amount: 1, target_user: target_user, message: 'test') }.to change { Message.count }.by(1)
    end

    context 'target user blocked with ToS reason' do
      before { UserManager.new(target_user).lock(:tos) }

      it 'does not send email about contribution to target user' do
        expect { manager.create(amount: 1, target_user: target_user) }.not_to deliver_email(to: target_user, subject: /You have received a contribution/)
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
      context '$500 in 1 week' do
        before do
          ContributionManager.new(user: user).create(amount: 100_00, target_user: create(:user, :profile_owner, contributions_enabled: true, subscribers_count: 5))
          Timecop.travel(1.day.since) do
            ContributionManager.new(user: user).create(amount: 100_00, target_user: create(:user, :profile_owner, contributions_enabled: true, subscribers_count: 5))
          end

          Timecop.travel(2.days.since) do
            ContributionManager.new(user: user).create(amount: 100_00, target_user: create(:user, :profile_owner, contributions_enabled: true, subscribers_count: 5))
          end

          Timecop.travel(3.days.since) do
            ContributionManager.new(user: user).create(amount: 100_00, target_user: create(:user, :profile_owner, contributions_enabled: true, subscribers_count: 5))
          end
        end

        specify do
          Timecop.travel(4.days.since) do
            expect { ContributionManager.new(user: user).create(amount: 100_00, target_user: create(:user, :profile_owner, contributions_enabled: true, subscribers_count: 5)) }.to change { user.reload.locked? }.to(true)
          end
        end

        specify do
          Timecop.travel(4.days.since) do
            expect { ContributionManager.new(user: user).create(amount: 100_00, target_user: create(:user, :profile_owner, contributions_enabled: true, subscribers_count: 5)) }.to change { user.reload.lock_reason }.to('weekly_contribution_limit')
          end
        end
      end
    end

    context 'huge contribution' do
      context 'too huge' do
        it { expect { manager.create(amount: 100000000000000000000, target_user: target_user) }.to raise_error(ManagerError, /large/) }
      end

      it 'has $100 limit' do
        expect { manager.create(amount: 10001, target_user: target_user) rescue nil }.not_to create_record(Contribution)
      end

      it 'creates contribution request' do
        expect { manager.create(amount: 10001, target_user: target_user) rescue nil }.to create_record(ContributionRequest).matching(user: user, target_user: target_user, amount: 10001)
      end

      it do
        expect { manager.create(amount: 10001, target_user: target_user) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(amount: t_error(:contribution_limit_reached)) }
      end

      context 'verified profile owner' do
        before { UserProfileManager.new(target_user).toggle_accepting_large_contributions; target_user.reload }

        it 'allows contributing up to 1000$' do
          expect { manager.create(amount: 100000, target_user: target_user) }.to create_record(Contribution).matching(amount: 100000, user: user, target_user: target_user)
        end

        it 'does not allow contributing more than 1000$' do
          expect { manager.create(amount: 100001, target_user: target_user) rescue nil }.not_to create_record(Contribution)
        end

        context 'multiple contributions' do
          before do
            manager.create(amount: 50000, target_user: target_user)
          end

          it 'allows contributing up to 1000$' do
            expect { manager.create(amount: 50000, target_user: target_user) }.to create_record(Contribution).matching(amount: 50000, user: user, target_user: target_user)
          end

          it 'does not allow contributing more than 1000$' do
            expect { manager.create(amount: 50001, target_user: target_user) rescue nil }.not_to create_record(Contribution)
          end
        end
      end

      context 'multiple contributions' do
        before do
          manager.create(amount: 6000, target_user: target_user)
        end

        it 'has $100 limit' do
          expect { manager.create(amount: 4001, target_user: target_user) rescue nil }.not_to create_record(Contribution)
        end

        it do
          expect { manager.create(amount: 4001, target_user: target_user) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(amount: t_error(:contribution_limit_reached)) }
        end

        context 'to multiple profiles' do
          let(:another_target_user) { create_profile email: 'another_target@gmail.com' }

          before do
            5.times do |i|
              SubscriptionManager.new(subscriber: create_user(email: "another_subscriber_#{i}@test.com")).subscribe_to(another_target_user)
            end
          end

          it do
            expect { manager.create(amount: 4001, target_user: another_target_user) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(amount: t_error(:contribution_limit_reached)) }
          end
        end

        context 'made with 24 hours interval' do
          it 'resets daily limit' do
            Timecop.travel 24.hours.since do
              expect { manager.create(amount: 9900, target_user: target_user) }.to create_record(Contribution).matching(user: user, target_user: target_user, amount: 9900)
            end
          end
        end
      end

      context 'with pending contribution request' do
        before { user.contribution_requests.create!(target_user: target_user, amount: 10001) }

        context 'to the same user' do
          it do
            expect { manager.create(amount: 10001, target_user: target_user) rescue nil }.not_to create_record(Contribution)
          end
          it do
            expect { manager.create(amount: 10001, target_user: target_user) rescue nil }.not_to create_record(ContributionRequest)
          end
          it do
            expect { manager.create(amount: 10001, target_user: target_user) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(amount: t_error(:contribution_limit_reached)) }
          end
        end

        context 'to different user' do
          let(:another_target_user) { create_profile email: 'another_target@gmail.com' }

          before do
            5.times do |i|
              SubscriptionManager.new(subscriber: create_user(email: "another_subscriber_#{i}@test.com")).subscribe_to(another_target_user)
            end
          end

          it do
            expect { manager.create(amount: 10001, target_user: another_target_user) rescue nil }.not_to create_record(Contribution)
          end
          it do
            expect { manager.create(amount: 10001, target_user: another_target_user) rescue nil }.to create_record(ContributionRequest)
          end
          it do
            expect { manager.create(amount: 10001, target_user: another_target_user) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(amount: t_error(:contribution_limit_reached)) }
          end
        end
      end

      context 'with approved contribution request' do
        let(:request) { user.contribution_requests.create!(target_user: target_user, amount: 10001) }

        before { ContributionManager.new(user: user).approve!(request) }

        it do
          expect { manager.create(amount: 10001, target_user: target_user) rescue nil }.to create_record(Contribution)
        end

        it 'has $500 limit' do
          expect { another_manager.create(amount: 50001, target_user: target_user) rescue nil }.not_to create_record(Contribution)
        end

        it do
          expect { manager.create(amount: 50001, target_user: target_user) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(amount: t_error(:contribution_limit_reached)) }
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
      let(:another_target_user) { create_profile email: 'another_target@gmail.com' }

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

    context 'charge fails' do
      before do
        StripeMock.prepare_card_error(:card_declined)
      end

      it 'does not create event about new contribution' do
        expect { manager.create_child rescue nil }.not_to create_event(:contribution_created)
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
    let(:request) { user.contribution_requests.create!(target_user: target_user, amount: 10001) }

    it 'creates contribution' do
      expect { manager.approve!(request) }.to create_record(Contribution).matching(user: user, target_user: target_user, amount: 10001)
    end

    it 'approves request' do
      expect { manager.approve!(request) }.to change { request.approved? }.from(false).to(true)
    end

    it 'performs request' do
      expect { manager.approve!(request) }.to change { request.performed? }.from(false).to(true)
    end
  end
end
