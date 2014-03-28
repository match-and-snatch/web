require 'spec_helper'

describe UserProfileManager do
  let(:user) { create_user }
  subject(:manager) { described_class.new(user) }

  describe '#update' do
    specify do
      expect { manager.update(subscription_cost: 1, slug: 'some-random-slug') }.not_to raise_error
    end

    it 'updates slug' do
      expect { manager.update(subscription_cost: 1, slug: 'obama') }.to change(user, :slug).to('obama')
    end

    it 'updates subscription_cost' do
      expect { manager.update(subscription_cost: 5, slug: 'obama') }.to change(user, :subscription_cost).to(5.0)
      expect { manager.update(subscription_cost: ' 6.1', slug: 'obama') }.to change(user, :subscription_cost).to(6.1)
    end

    context 'empty subscription_cost' do
      specify do
        expect { manager.update(subscription_cost: '', slug: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(subscription_cost: t_error(:empty)) }
      end

      specify do
        expect { manager.update(subscription_cost: 0, slug: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(subscription_cost: t_error(:zero)) }
      end
    end

    context 'empty slug' do
      specify do
        expect { manager.update(subscription_cost: 1, slug: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(slug: t_error(:empty)) }
      end
    end

    context 'trailing spaces in slug' do
      specify do
        expect { manager.update(subscription_cost: 1, slug: ' obama ') }.not_to raise_error
      end
    end

    context 'upcase in slug' do
      specify do
        expect { manager.update(subscription_cost: 1, slug: 'FUck') }.not_to raise_error
      end
    end

    context 'underscore in slug' do
      specify do
        expect { manager.update(subscription_cost: 1, slug: 'obama_the_president') }.not_to raise_error
      end
    end

    context 'numbers in slug' do
      specify do
        expect { manager.update(subscription_cost: 1, slug: 'agent-007') }.not_to raise_error
      end
      specify do
        expect { manager.update(subscription_cost: 1, slug: '007-agent') }.not_to raise_error
      end
      specify do
        expect { manager.update(subscription_cost: 1, slug: 'a-007-gent') }.not_to raise_error
      end
    end

    context 'invalid slug' do
      specify do
        expect { manager.update(subscription_cost: 1, slug: '?obama') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(slug: t_error(:not_a_slug)) }
      end
      specify do
        expect { manager.update(subscription_cost: 1, slug: 'obama?') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(slug: t_error(:not_a_slug)) }
      end
      specify do
        expect { manager.update(subscription_cost: 1, slug: '------') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(slug: t_error(:not_a_slug)) }
      end
      specify do
        expect { manager.update(subscription_cost: 1, slug: '______') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(slug: t_error(:not_a_slug)) }
      end
      specify do
        expect { manager.update(subscription_cost: 1, slug: 'obama-') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(slug: t_error(:not_a_slug)) }
      end
      specify do
        expect { manager.update(subscription_cost: 1, slug: '-obama') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(slug: t_error(:not_a_slug)) }
      end
    end

    context 'slug already taken' do
      context 'subscriber' do
        let!(:another_user) { create_user(email: 'obama@prezident.us', first_name: 'Obama', last_name: 'Prezident') }

        specify do
          expect { manager.update(subscription_cost: 1, slug: 'obama-prezident') }.not_to raise_error
        end
      end

      context 'owner' do
        let!(:another_user) { create_user(email: 'obama@prezident.us', first_name: 'Obama', last_name: 'Prezident', is_profile_owner: true) }

        specify do
          expect { manager.update(subscription_cost: 1, slug: 'obama-prezident') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(slug: t_error(:taken)) }
        end
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