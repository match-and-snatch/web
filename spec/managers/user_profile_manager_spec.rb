require 'spec_helper'

describe UserProfileManager do
  let(:user) { create_user }
  subject(:manager) { described_class.new(user) }

  describe '#update' do
    specify do
      expect { manager.update(subscription_cost: 1, profile_name: 'some-random-name') }.not_to raise_error
    end

    it 'updates slug' do
      expect { manager.update(subscription_cost: 1, profile_name: 'obama') }.to change(user, :slug).to('obama')
    end

    it 'updates subscription_cost' do
      expect { manager.update(subscription_cost: 5, profile_name: 'obama') }.to change(user, :subscription_cost).to(5.0)
      expect { manager.update(subscription_cost: ' 6.1', profile_name: 'obama') }.to change(user, :subscription_cost).to(6.1)
    end

    context 'empty subscription_cost' do
      specify do
        expect { manager.update(subscription_cost: '', profile_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(subscription_cost: t_error(:empty)) }
      end

      specify do
        expect { manager.update(subscription_cost: 0, profile_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(subscription_cost: t_error(:zero)) }
      end
    end

    context 'empty slug' do
      specify do
        expect { manager.update(subscription_cost: 1, profile_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(profile_name: t_error(:empty)) }
      end
    end

    context 'trailing spaces in slug' do
      specify do
        expect { manager.update(subscription_cost: 1, profile_name: ' obama ') }.not_to raise_error
      end
    end

    context 'upcase in slug' do
      specify do
        expect { manager.update(subscription_cost: 1, profile_name: 'FUck') }.not_to raise_error
      end
    end

    context 'underscore in slug' do
      specify do
        expect { manager.update(subscription_cost: 1, profile_name: 'obama_the_president') }.not_to raise_error
      end
    end

    context 'numbers in slug' do
      specify do
        expect { manager.update(subscription_cost: 1, profile_name: 'agent-007') }.not_to raise_error
      end
      specify do
        expect { manager.update(subscription_cost: 1, profile_name: '007-agent') }.not_to raise_error
      end
      specify do
        expect { manager.update(subscription_cost: 1, profile_name: 'a-007-gent') }.not_to raise_error
      end
    end
  end

  describe '#update_payment_information' do
    specify do
      expect { manager.update_payment_information(holder_name: 'holder', routing_number: '123456789', account_number: '000123456789') }.to change(user, :holder_name).to('holder')
    end
    specify do
      expect { manager.update_payment_information(holder_name: 'holder', routing_number: '123456789', account_number: '000123456789') }.to change(user, :routing_number).to('123456789')
    end
    specify do
      expect { manager.update_payment_information(holder_name: 'holder', routing_number: '123456789', account_number: '000123456789') }.to change(user, :account_number).to('000123456789')
    end

    context 'empty holder name' do
      specify do
        expect { manager.update_payment_information(holder_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to have_key(:holder_name) }
      end
    end

    context 'invalid routing number' do
      specify do
        expect { manager.update_payment_information(routing_number: 'whatever') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(routing_number: t_error(:not_an_integer)) }
      end

      specify do
        expect { manager.update_payment_information(routing_number: '12345678') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(routing_number: t_error(:not_a_routing_number)) }
      end
    end

    context 'invalid account number' do
      specify do
        expect { manager.update_payment_information(account_number: 'whatever') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(account_number: t_error(:not_an_integer)) }
      end

      specify do
        expect { manager.update_payment_information(account_number: '12345678') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(account_number: t_error(:not_an_account_number)) }
      end
    end
  end
end