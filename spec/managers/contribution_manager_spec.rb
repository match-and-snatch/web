require 'spec_helper'

describe ContributionManager do
  subject(:manager) { ContributionManager.new(user: user, contribution: contribution) }
  let(:contribution) { nil }

  let(:user) { create_user }
  let(:target_user) { create_profile email: 'target@gmail.com' }

  before { StripeMock.start }
  after { StripeMock.stop }

  describe '#create' do
    it 'creates new contribution' do
      expect(manager.create(amount: 1, target_user: target_user)).to be_a(Contribution)
    end

    it do
      expect(manager.create(amount: 1, target_user: target_user)).not_to be_a_new_record
    end

    it do
      expect { manager.create(amount: 1, target_user: target_user) }.to change { Contribution.count }.by(1)
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

    context 'zero amount' do
      it do
        expect { manager.create(amount: 0, target_user: target_user) }.to raise_error(ManagerError, /zero/)
      end

      it do
        expect { manager.create(amount: nil, target_user: target_user) }.to raise_error(ManagerError, /zero/)
      end
    end

    context 'huge contribution' do
      it 'has $100 limit' do
        expect { manager.create(amount: 10001, target_user: target_user) rescue nil }.not_to create_record(Contribution)
      end

      it do
        expect { manager.create(amount: 10001, target_user: target_user) }.to raise_error(ManagerError, /You can't contribute more than \$100/)
      end

      context 'multiple contributions' do
        before do
          manager.create(amount: 6000, target_user: target_user)
        end

        it 'has $100 limit' do
          expect { manager.create(amount: 4001, target_user: target_user) rescue nil }.not_to create_record(Contribution)
        end

        it do
          expect { manager.create(amount: 4001, target_user: target_user) }.to raise_error(ManagerError, /You can't contribute more than \$100/)
        end

        context 'to multiple profiles' do
          let(:another_target_user) { create_profile email: 'another_target@gmail.com' }

          it do
            expect { manager.create(amount: 4001, target_user: another_target_user) }.to raise_error(ManagerError, /You can't contribute more than \$100/)
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
end
