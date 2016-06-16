require 'spec_helper'

describe PaymentManager do
  subject { PaymentManager.new(user: user) }

  let(:user) { create :user, :with_cc }
  let(:target_user) { create :user, :profile_owner }

  before { StripeMock.start }
  after { StripeMock.stop }

  describe '#pay_for' do
    let(:subscription) { create :subscription, user: user, target_user: target_user, charged_at: nil }

    context 'user is not activated yet' do
      let(:user) { create :user, :with_cc, activated: false }

      it 'activates subscriber' do
        expect { subject.pay_for(subscription) }.to change { user.reload.activated? }.to(true)
      end
    end

    it 'creates payment_created event' do
      expect { subject.pay_for(subscription) }.to create_event(:payment_created)
    end

    it 'logs gross sales' do
      expect { subject.pay_for(subscription) }.to change { target_user.gross_sales }.from(0).to(599)
    end

    it 'sets stripe charge id' do
      expect { subject.pay_for(subscription) }.to create_record(Payment).once.matching(stripe_charge_id: 'test_ch_1')
    end

    it 'sets contry code' do
      expect { subject.pay_for(subscription) }.to create_record(Payment).once.matching(source_country: 'US')
    end

    it 'sets address data' do
      expect { subject.pay_for(subscription) }.to create_record(Payment).once.matching(billing_address_city: user.billing_address_city,
                                                                                       billing_address_country: user.billing_address_country,
                                                                                       billing_address_line_1: user.billing_address_line_1,
                                                                                       billing_address_line_2: user.billing_address_line_2,
                                                                                       billing_address_state: user.billing_address_state,
                                                                                       billing_address_zip: user.billing_address_zip)
    end

    context 'address specified in card' do
      let(:cc_token) do
        StripeMock.generate_card_token(address_city: 'Krasnoyarsk',
                                       address_country: 'Russia',
                                       address_line1: 'Lenina 1',
                                       address_line2: 'Mira 2',
                                       address_state: 'Kras',
                                       address_zip: '123456')
      end
      let(:customer) { Stripe::Customer.create(email: 'asd@asd.com', source: cc_token) }
      let(:user) { create :user, :with_cc, stripe_user_id: customer.id }

      it 'sets address data' do
        expect { subject.pay_for(subscription) }.to create_record(Payment).once.matching(billing_address_city: 'Krasnoyarsk',
                                                                                         billing_address_country: 'Russia',
                                                                                         billing_address_line_1: 'Lenina 1',
                                                                                         billing_address_line_2: 'Mira 2',
                                                                                         billing_address_state: 'Kras',
                                                                                         billing_address_zip: '123456')
      end
    end

    context 'subscription is paid' do
      let(:subscription) { create :subscription, user: user, target_user: target_user, charged_at: 1.day.ago }
      specify { expect { subject.pay_for(subscription) }.to raise_error(PaymentError, /is not payable/) }
    end

    context 'target user locked' do
      context 'billing lock' do
        let(:target_user) { create :user, :profile_owner, locked: true, lock_type: 'billing' }
        specify { expect { subject.pay_for(subscription) }.not_to raise_error }
      end

      context 'account lock' do
        let(:target_user) { create :user, :profile_owner, locked: true, lock_type: 'account' }
        specify { expect { subject.pay_for(subscription) }.to raise_error(PaymentError, /is not payable/) }
      end

      context 'tos lock' do
        let(:target_user) { create :user, :profile_owner, locked: true, lock_type: 'tos' }
        specify { expect { subject.pay_for(subscription) }.to raise_error(PaymentError, /is not payable/) }
      end
    end

    context 'profile owner is on vacation' do
      before do
        UserProfileManager.new(target_user).enable_vacation_mode(reason: 'Super reason')
      end

      specify { expect { subject.pay_for(subscription) }.not_to raise_error }
      specify { expect { subject.pay_for(subscription) }.to create_event(:payment_created) }
      it 'logs gross sales' do
        expect { subject.pay_for(subscription) }.to change { target_user.gross_sales }.from(0).to(599)
      end
    end

    context 'billing failed' do
      before do
        UserManager.new(user).mark_billing_failed
        SubscriptionManager.new(subscriber: user, subscription: subscription).reject
        UserStatsManager.new(target_user).log_subscriptions_count
      end

      context 'payment passes' do
        it 'restores billing status to valid' do
          expect { subject.pay_for(subscription) }.to change { user.reload.billing_failed? }.to(false)
        end

        it 'restores rejected status to valid' do
          expect { subject.pay_for(subscription) }.to change { subscription.rejected }.to(false)
        end

        it 'removes rejected date' do
          expect { subject.pay_for(subscription) }.to change { subscription.rejected_at }.to(nil)
        end

        it 'creates payment_created event' do
          expect { subject.pay_for(subscription) }.to create_event(:payment_created)
        end

        it 'logs gross sales' do
          expect { subject.pay_for(subscription) }.to change { target_user.gross_sales }.from(0).to(599)
        end

        it 'increases subscriptions count daily statistic' do
          expect { subject.pay_for(subscription) }.to change { target_user.subscription_daily_count_change_events.last.subscriptions_count }.from(0).to(1)
        end
        it 'dos not change unsubscribers count daily statistic' do
          expect { subject.pay_for(subscription) }.not_to change { target_user.subscription_daily_count_change_events.last.unsubscribers_count }.from(0)
        end
        it 'decreases failed payments count daily statistic' do
          expect { subject.pay_for(subscription) }.to change { target_user.subscription_daily_count_change_events.last.failed_payments_count }.from(1).to(0)
        end
      end

      context 'payment fails' do
        let(:pay_with_failed_card) { subject.pay_for(subscription) }

        before do
          StripeMock.prepare_card_error(:card_declined)
          pay_with_failed_card
          StripeMock.prepare_card_error(:card_declined)
        end

        it 'marks as rejected and sets rejected date', freeze: true do
          expect(subscription.rejected).to eq(true)
          expect(subscription.rejected_at.to_s).to eq(Time.zone.now.to_s)
        end

        it 'does not create event about new payment' do
          expect { subject.pay_for(subscription) rescue nil }.not_to create_event(:payment_created)
        end

        it 'does not log gross sales' do
          expect { subject.pay_for(subscription) }.not_to change { target_user.gross_sales }
        end

        it 'creates payment_failed event' do
          expect { subject.pay_for(subscription) }.to create_event(:payment_failed)
        end

        it 'does not change subscriptions count daily statistic' do
          expect { subject.pay_for(subscription) }.not_to change { target_user.subscription_daily_count_change_events.last.subscriptions_count }.from(0)
        end
        it 'dos not change unsubscribers count daily statistic' do
          expect { subject.pay_for(subscription) }.not_to change { target_user.subscription_daily_count_change_events.last.unsubscribers_count }.from(0)
        end
        it 'does not change failed payments count daily statistic' do
          expect { subject.pay_for(subscription) }.not_to change { target_user.subscription_daily_count_change_events.last.failed_payments_count }.from(1)
        end

        context 'on a day when payment fails first time' do
          it 'does not restore billing status' do
            expect { subject.pay_for(subscription) }.not_to change { user.reload.billing_failed? }
          end

          describe 'notifications' do
            let(:pay_with_failed_card) {}

            it 'notifies user about payment failure' do
              expect(PaymentsMailer).to receive(:failed).once.and_return(double('mailer').as_null_object)
              subject.pay_for(subscription)
            end

            context 'user billing recently failed' do
              before do
                PaymentFailure.create!(user: user, created_at: 1.hour.ago)
              end

              it 'does not produce duplicate notifications in a short period of time' do
                expect(PaymentsMailer).not_to receive(:failed)
                subject.pay_for(subscription)
              end
            end

            context 'billing failed long time ago' do
              before do
                PaymentFailure.create!(user: user, created_at: 5.hours.ago)
              end

              it 'notifies user about payment failure' do
                expect(PaymentsMailer).to receive(:failed).once.and_return(double('mailer').as_null_object)
                subject.pay_for(subscription)
              end
            end
          end

          it 'does not unsubscribe user' do
            expect { subject.pay_for(subscription) }.not_to change { subscription.reload.removed? }.from(false)
          end
        end

        describe 'recurring payments' do
          def pay
            Timecop.freeze(current_date) do
              subject.pay_for(subscription)
            end
          end

          after(:each) { pay }

          context 'on first day after payment failure' do
            let(:current_date) { 1.day.from_now }

            it 'does not restore billing status' do
              expect { pay }.not_to change { user.reload.billing_failed? }
            end

            it 'notifies user about payment failure' do
              expect(PaymentsMailer).to receive(:failed).and_return(double('mailer').as_null_object)
            end

            it 'does not unsubscribe user' do
              expect { pay }.not_to change { subscription.reload.removed? }.from(false)
            end
          end

          context 'on second try' do
            let(:current_date) { 2.days.from_now }

            it 'does not restore billing status' do
              expect { pay }.not_to change { user.reload.billing_failed? }
            end

            it 'notifies user about payment failure' do
              expect(PaymentsMailer).not_to receive(:failed)
            end

            it 'does not unsubscribe user' do
              expect { pay }.not_to change { subscription.reload.removed? }.from(false)
            end
          end

          context 'on third try' do
            let(:current_date) { 3.days.from_now }

            it 'does not restore billing status' do
              expect { pay }.not_to change { user.reload.billing_failed? }
            end

            it 'notifies user about payment failure' do
              expect(PaymentsMailer).to receive(:failed).and_return(double('mailer').as_null_object)
            end

            it 'does not unsubscribe user' do
              expect { pay }.not_to change { subscription.reload.removed? }.from(false)
            end
          end

          context 'on fourth try' do
            let(:current_date) { 4.days.from_now }

            it 'does not restore billing status' do
              expect { pay }.not_to change { user.reload.billing_failed? }
            end

            it 'notifies user about payment failure' do
              expect(PaymentsMailer).not_to receive(:failed)
            end

            it 'does not unsubscribe user' do
              expect { pay }.not_to change { subscription.reload.removed? }.from(false)
            end
          end

          context 'on eighth try' do
            let(:current_date) { 8.days.from_now }

            it 'does not restore billing status' do
              expect { pay }.not_to change { user.reload.billing_failed? }
            end

            it 'notifies user about payment failure' do
              expect(PaymentsMailer).to receive(:failed).and_return(double('mailer').as_null_object)
            end

            it 'unsubscribes user' do
              expect { pay }.to change { subscription.reload.removed? }.from(false).to(true)
            end

            it 'does not change subscriptions count daily statistic' do
              expect { pay }.not_to change { target_user.subscription_daily_count_change_events.last.subscriptions_count }.from(0)
            end
            it 'increase unsubscribers count daily statistic' do
              expect { pay }.to change { target_user.subscription_daily_count_change_events.last.unsubscribers_count }.from(0).to(1)
            end
            it 'does not change failed payments count daily statistic' do
              expect { pay }.not_to change { target_user.subscription_daily_count_change_events.last.failed_payments_count }.from(1)
            end
          end

          context 'on any day after subscription is expired' do
            let(:current_date) { 9.days.from_now }

            it 'does not restore billing status' do
              expect { pay }.not_to change { user.reload.billing_failed? }
            end

            it 'notifies user about payment failure' do
              expect(PaymentsMailer).to receive(:failed).and_return(double('mailer').as_null_object)
            end

            it 'unsubscribes user' do
              expect { pay }.to change { subscription.reload.removed? }.from(false).to(true)
            end
          end
        end
      end

      context 'payment fails by api error' do
        before { StripeMock.prepare_error(Stripe::APIError.new("Api is down"), :new_charge) }

        it 'marks as rejected and sets rejected date', freeze: true do
          expect(subscription.rejected).to eq(true)
          expect(subscription.rejected_at.to_s).to eq(Time.zone.now.to_s)
        end

        it 'create payment_failed event' do
          expect { subject.pay_for(subscription) }.to create_event(:payment_failed)
        end

        it 'marks subscription as processing payment' do
          expect { subject.pay_for(subscription) }.to change { subscription.processing_payment }.from(false).to(true)
        end
      end
    end
  end

  describe '#perform_test_payment' do
    context 'subscription is not paid' do
      let!(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(target_user) }

      context 'user never had billing active' do
        it 'does not charge user' do
          expect { subject.perform_test_payment }.to change { subscription.reload.charged_at }
        end

        specify do
          expect { subject.perform_test_payment }.to create_record(Payment).
            matching(target_id: subscription.id, target_type: 'Subscription')
        end
      end

      context 'user had active billing' do
        before do
          create :payment, user: user
        end

        it 'pays for subscriptions on charge' do
          expect { subject.perform_test_payment }.to change { subscription.reload.charged_at }
        end
      end
    end

    context 'subscription is already paid' do
      before do
        stub_const('Stripe::Customer', double('customer').as_null_object)
        UserProfileManager.new(user).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
        user.reload
      end

      let!(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(target_user) }

      it 'does not pay for already paid subscriptions' do
        expect { subject.perform_test_payment }.not_to change { subscription.reload.charged_at }
      end
    end
  end
end
