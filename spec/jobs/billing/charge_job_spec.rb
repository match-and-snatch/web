require 'spec_helper'

describe Billing::ChargeJob do
  describe '.perform' do
    subject(:perform) { described_class.new.perform }

    it { expect { perform }.to deliver_email(to: 'debug@connectpal.com', subject: /Charge Job/) }
    
    context 'no subscriptions on charge' do
      specify do
        expect { perform }.not_to raise_error
      end
    end

    before { StripeMock.start }
    after { StripeMock.stop }

    let(:user) { create_user }
    let(:target_user) { create_profile email: 'target@user.com' }

    before do
      UserProfileManager.new(user).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
      user.reload
    end

    context 'subscription on charge' do
      let!(:unpaid_subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(target_user) }
      let!(:paid_subscription) { SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(create_profile email: 'another@one.com') }
      let!(:invalid_subscription) do
        profile = create_profile email: 'invalid@one.com'

        SubscriptionManager.new(subscriber: user).subscribe_to(profile).tap do
          UserProfileManager.new(profile).delete_profile_page!
        end
      end

      it 'does not create new subscriptions' do
        expect { perform }.not_to change { Subscription.count }
      end

      it 'creates payment' do
        expect { perform }.to change { Payment.count }.by(1)
      end

      it 'creates payment on unpaid subscription' do
        expect { perform }.to change { unpaid_subscription.payments.count }.by(1)
      end

      it 'changes charge date' do
        expect { perform }.to change { unpaid_subscription.reload.charged_at }
      end

      context 'profile owner on vacation' do
        before do
          UserProfileManager.new(target_user).enable_vacation_mode(reason: 'No reason')
        end

        it 'does not create any payments' do
          expect { perform }.not_to change { unpaid_subscription.payments.count }
        end
      end

      context 'subscriber on vacation' do
        before do
          UserProfileManager.new(user).enable_vacation_mode(reason: 'No reason given')
        end

        it 'creates payment' do
          expect { perform }.to change { unpaid_subscription.payments.count }.by(1)
        end
      end

      context 'having invalid subscription without user set' do
        before do
          subscriber = create_user email: 'invalid@two.com'
          subscription = SubscriptionManager.new(subscriber: subscriber).subscribe_to(target_user)
          subscription.update_attribute(:user_id, nil)
        end

        specify do
          expect { perform }.not_to raise_error
        end
      end
    end

    describe 'vacation flow' do
      let(:create_subscription) {
        #Timecop.freeze(charge_date) do
          SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(target_user)
        #end
      }

      let(:charge_date) { Time.zone.parse('2000-12-31') }

      after { Timecop.return }

      context 'subscribed before vacation started' do
        before do
          Timecop.freeze(Date.new(2001, 01, 01)) do
            @subscription = create_subscription
          end

          Timecop.freeze(Date.new(2001, 01, 15)) do
            UserProfileManager.new(target_user).enable_vacation_mode(reason: 'Reason')
          end
        end

        context 'vacation ended before next billing date' do
          before do
            Timecop.freeze Date.new(2001, 01, 20)
            UserProfileManager.new(target_user).disable_vacation_mode
          end

          it 'does not charge subscriber' do
            expect { perform }.not_to change { Payment.count }
          end

          specify do
            expect { perform }.not_to change { @subscription.reload.charged_at }
          end
        end

        context 'vacation ended after next billing date' do
          before do
            Timecop.freeze Date.new(2001, 03, 10)
            UserProfileManager.new(target_user).disable_vacation_mode
          end

          it 'charges subscriber only once for 1 month' do
            expect { perform }.to change { Payment.count } # ?
          end

          specify do
            expect { perform }.to change { @subscription.reload.charged_at } # ?
          end
        end
      end

      context 'subscribed within vacation period' do
        before do
          Timecop.freeze(Date.new(2001, 01, 01)) do
            UserProfileManager.new(target_user).enable_vacation_mode(reason: 'Reason')
          end

          Timecop.freeze(Date.new(2001, 01, 15)) do
            @subscription = create_subscription
          end
        end

        context 'vacation ended before next billing date' do
          before do
            Timecop.freeze Date.new(2001, 02, 01)
            UserProfileManager.new(target_user).disable_vacation_mode
          end

          it 'does not charge subscriber' do
            expect { perform }.not_to change { Payment.count }
          end

          specify do
            expect { perform }.not_to change { @subscription.reload.charged_at }
          end
        end

        context 'vacation ended after next billing date' do
          context 'billing is not suspended' do
            before do
              Timecop.freeze Date.new(2001, 02, 25)
              UserProfileManager.new(target_user).disable_vacation_mode
            end

            it 'charges subscriber only once for 1 month' do
              expect { perform }.to change { Payment.count }.by(1)
            end

            specify do
              expect { perform }.to change { @subscription.reload.charged_at }.to(Time.zone.now)
            end
          end
        end
      end
    end
  end
end
