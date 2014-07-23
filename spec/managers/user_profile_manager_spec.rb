require 'spec_helper'

describe UserProfileManager do
  let(:user) { create_user }
  subject(:manager) { described_class.new(user) }

  describe '#add_profile_type' do
    let(:profile_type) { ProfileTypeManager.new.create(title: 'test') }

    specify do
      expect(user.profile_types).to be_empty
    end

    specify do
      expect { manager.add_profile_type(profile_type) }.to change(user.profile_types, :count).from(0).to(1)
      expect(user.profile_types).to include(profile_type)
    end
  end

  describe '#remove_profile_type' do
    let(:profile_type) { ProfileTypeManager.new.create(title: 'test') }

    before { manager.add_profile_type(profile_type) }

    specify do
      expect { manager.remove_profile_type(profile_type) }.to change(user.profile_types, :count).from(1).to(0)
      expect(user.profile_types).not_to include(profile_type)
    end
  end

  describe '#update' do
    specify do
      expect { manager.update(cost: 1, profile_name: 'some-random-name', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.not_to raise_error
    end

    it 'updates slug' do
      expect { manager.update(cost: 1, profile_name: 'obama', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.to change(user, :slug).to('obama')
    end

    it 'updates cost' do
      expect { manager.update(cost: 5, profile_name: 'obama', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.to change(user, :cost).to(5.0)
      expect { manager.update(cost:' 6', profile_name: 'obama', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.to change(user, :cost).to(6)
    end

    context 'empty cost' do
      specify do
        expect { manager.update(cost: '', profile_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:empty)) }
      end

      specify do
        expect { manager.update(cost: 0, profile_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:zero)) }
      end

      specify do
        expect { manager.update(cost: '-100', profile_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:not_an_integer)) }
      end

      specify do
        expect { manager.update(cost: -200, profile_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:not_an_integer)) }
      end
    end

    context 'empty slug' do
      specify do
        expect { manager.update(cost: 1, profile_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(profile_name: t_error(:empty)) }
      end
    end

    context 'trailing spaces in slug' do
      specify do
        expect { manager.update(cost: 1, profile_name: ' obama ', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.not_to raise_error
      end
    end

    context 'upcase in slug' do
      specify do
        expect { manager.update(cost: 1, profile_name: 'FUck', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.not_to raise_error
      end
    end

    context 'underscore in slug' do
      specify do
        expect { manager.update(cost: 1, profile_name: 'obama_the_president', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.not_to raise_error
      end
    end

    context 'numbers in slug' do
      specify do
        expect { manager.update(cost: 1, profile_name: 'agent-007', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.not_to raise_error
      end
      specify do
        expect { manager.update(cost: 1, profile_name: '007-agent', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.not_to raise_error
      end
      specify do
        expect { manager.update(cost: 1, profile_name: 'a-007-gent', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.not_to raise_error
      end
    end

    describe 'payment information' do
      specify do
        expect { manager.update(cost: 1, profile_name: 'obama', holder_name: 'holder', routing_number: '123456789', account_number: '000123456789') }.to change(user, :holder_name).to('holder')
      end
      specify do
        expect { manager.update(cost: 1, profile_name: 'obama', holder_name: 'holder', routing_number: '123456789', account_number: '000123456789') }.to change(user, :routing_number).to('123456789')
      end
      specify do
        expect { manager.update(cost: 1, profile_name: 'obama', holder_name: 'holder', routing_number: '123456789', account_number: '000123456789') }.to change(user, :account_number).to('000123456789')
      end

      context 'empty holder name' do
        specify do
          expect { manager.update(cost: 1, profile_name: 'obama', holder_name: '', routing_number: '123456789', account_number: '000123456789') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to have_key(:holder_name) }
        end
      end

      context 'entire empty payment information' do
        specify do
          expect { manager.update(cost: 1, profile_name: 'obama', holder_name: '', routing_number: '', account_number: '') }.not_to raise_error
        end
      end

      context 'invalid routing number' do
        specify do
          expect { manager.update(routing_number: 'whatever') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(routing_number: t_error(:not_an_integer)) }
        end

        specify do
          expect { manager.update(routing_number: '12345678') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(routing_number: t_error(:not_a_routing_number)) }
        end
      end

      context 'invalid account number' do
        specify do
          expect { manager.update(account_number: 'whatever') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(account_number: t_error(:not_an_integer)) }
        end

        specify do
          expect { manager.update(account_number: '12345678') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(account_number: t_error(:not_an_account_number)) }
        end
      end
    end
  end

  describe '#update_cc_data' do
    before { StripeMock.start }
    after { StripeMock.stop }

    before do
      stub_const('Stripe::Customer', double('customer').as_null_object)
      UserManager.new(user).mark_billing_failed
    end

    specify do
      expect { manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018) }.to change { user.reload.billing_failed? }.to(false)
    end

    context 'user has outstanding payments' do
      let(:target_user) { create_profile }

      before do
        SubscriptionManager.new(user).subscribe_to(target_user)
      end

      it 'restores billing failed flag to false' do
        expect { manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018) }.to change { user.reload.billing_failed? }.to(false)
      end

      context 'test payment failed' do
        before do
          StripeMock.prepare_card_error(:card_declined)
        end

        it 'keeps flag in the failed state' do
          expect { manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018) }.not_to change { user.reload.billing_failed? }.from(false)
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

  describe '#update_contacts_info' do
    specify do
      expect { manager.update_contacts_info(twitter: 'http://twit.ru') }.to change { user.reload.contacts_info[:twitter] }.from(nil).to('http://twit.ru')
    end

    specify do
      expect { manager.update_contacts_info(twitter: 'https://twit.ru') }.to change { user.reload.contacts_info[:twitter] }.from(nil).to('https://twit.ru')
    end

    specify do
      expect { manager.update_contacts_info(twitter: 'https://www.twit.ru') }.to change { user.reload.contacts_info[:twitter] }.from(nil).to('https://www.twit.ru')
    end

    specify do
      expect { manager.update_contacts_info(twitter: 'https://www.twit.ru?id=123') }.to change { user.reload.contacts_info[:twitter] }.from(nil).to('https://www.twit.ru?id=123')
    end

    specify do
      expect { manager.update_contacts_info(twitter: 'twit.ru') }.to change { user.reload.contacts_info[:twitter] }.from(nil).to('http://twit.ru')
    end

    specify do
      expect { manager.update_contacts_info(twitter: ' ') }.not_to change { user.reload.contacts_info[:twitter] }
    end
  end
end
