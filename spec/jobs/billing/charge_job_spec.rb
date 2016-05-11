require 'spec_helper'

describe Billing::ChargeJob do
  describe '.perform' do
    subject(:perform) { described_class.new.perform }

    it { expect { perform }.to deliver_email(to: APP_CONFIG['emails']['reports'], subject: /Charge Job/) }

    context 'no subscriptions on charge' do
      specify do
        expect { perform }.not_to raise_error
      end
    end

    before { StripeMock.start }
    after { StripeMock.stop }

    let(:user) { create_user }
    let(:target_user) { create_profile email: 'target@user.com' }
    let(:failed_billing_subscriber) { create :user, :with_cc }

    before do
      UserProfileManager.new(user).update_cc_data(
        number: '4242424242424242',
        cvc: '333',
        expiry_month: '12',
        expiry_year: 2018,
        address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
      user.reload
    end

    context 'subscription on charge' do
      let!(:unpaid_subscription) do
        Timecop.travel(32.days.ago) do
          SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(target_user)
        end
      end

      let!(:failed_billing_subscription) do
        SubscriptionManager.new(subscriber: failed_billing_subscriber).subscribe_to(create :user, :profile_owner)
      end

      let!(:paid_subscription) do
        SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(create :user, :profile_owner)
      end

      let!(:invalid_subscription) do
        profile = create_profile email: 'invalid@one.com'

        SubscriptionManager.new(subscriber: user).subscribe_to(profile).tap do
          UserProfileManager.new(profile).delete_profile_page!
        end
      end

      it 'does not create new subscriptions' do
        expect { perform }.not_to create_record(Subscription)
      end

      it 'changes the charge date' do
        expect { perform }.to change { unpaid_subscription.reload.charged_at }
      end

      it 'creates a payment' do
        expect { perform }.to create_record(Payment).
          matching(target_id: unpaid_subscription.id, target_type: 'Subscription')
      end

      it 'does not charge subscribers with initially failed billing' do
        expect { perform }.not_to create_record(Payment).
          matching(target_id: failed_billing_subscription.id, target_type: 'Subscription')
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
