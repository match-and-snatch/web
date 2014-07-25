require 'spec_helper'

describe Subscription do
  let(:user) { create_user }
  let(:target_user) { create_profile email: 'target@user.com' }

  subject { SubscriptionManager.new(user).subscribe_to(target_user) }

  describe '.on_charge' do
    before { StripeMock.start }
    after { StripeMock.stop }

    before do
      UserProfileManager.new(user).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018)
      user.reload
    end

    let!(:unpaid_subscription) { SubscriptionManager.new(user).subscribe_to(target_user) }
    let!(:paid_subscription) { SubscriptionManager.new(user).subscribe_and_pay_for(create_profile email: 'another@one.com') }
    let!(:invalid_subscription) do
      profile = create_profile email: 'invalid@one.com'

      SubscriptionManager.new(user).subscribe_to(profile).tap do
        UserProfileManager.new(profile).delete_profile_page
      end
    end

    it 'returns unpaid subscriptions' do
      expect(described_class.on_charge).to eq([unpaid_subscription])
    end
  end

  describe '#notify_about_payment_failure?' do
    before { StripeMock.start }
    after { StripeMock.stop }

    context 'subscription is paid' do
      before do
        PaymentManager.new.pay_for(subject)
      end

      it 'notifies user about payment failure' do
        expect(subject.notify_about_payment_failure?).to eq(true)
      end

    end

    context 'payment failed' do
      before do
        StripeMock.prepare_card_error(:card_declined)
        PaymentManager.new.pay_for(subject)
      end

      it 'does notify' do
        expect(subject.notify_about_payment_failure?).to eq(true)
      end

      context 'on a next day' do
        it 'does notify' do
          expect(subject.notify_about_payment_failure?).to eq(true)
        end
      end

      context 'on the day after tomorrow' do
        it 'does not notify' do
          Timecop.freeze(2.days.from_now) do
            expect(subject.notify_about_payment_failure?).to eq(false)
          end
        end
      end

      context 'on second try' do
        it 'does notify' do
          Timecop.freeze(3.days.from_now) do
            expect(subject.notify_about_payment_failure?).to eq(true)
          end
        end
      end

      context 'on fourth day after failure' do
        it 'does notify' do
          Timecop.freeze(4.days.from_now) do
            expect(subject.notify_about_payment_failure?).to eq(false)
          end
        end
      end

      context 'eight days later (last try)' do
        it 'does notify' do
          Timecop.freeze(8.days.from_now) do
            expect(subject.notify_about_payment_failure?).to eq(true)
          end
        end
      end

      context 'any time later after last try' do
        it 'does notify' do
          Timecop.freeze(9.days.from_now) do
            expect(subject.notify_about_payment_failure?).to eq(true)
          end
        end
      end
    end
  end

  describe '#payment_attempts_expired?' do
    before { StripeMock.start }
    after { StripeMock.stop }

    context 'no payment failures' do
      specify do
        expect(subject.payment_attempts_expired?).to eq(false)
      end

      context 'on 8th day' do
        specify do
          Timecop.freeze(8.days.from_now) do
            expect(subject.payment_attempts_expired?).to eq(false)
          end
        end
      end
    end

    context 'payment has failed' do
      before do
        StripeMock.prepare_card_error(:card_declined)
        PaymentManager.new.pay_for(subject)
      end

      specify do
        expect(subject.payment_attempts_expired?).to eq(false)
      end

      context 'on 8th day' do
        specify do
          Timecop.freeze(8.days.from_now) do
            expect(subject.payment_attempts_expired?).to eq(true)
          end
        end
      end

      context 'on any day later' do
        specify do
          Timecop.freeze(9.days.from_now) do
            expect(subject.payment_attempts_expired?).to eq(true)
          end
        end
      end
    end
  end

  describe '#expired?' do
    context 'when removed' do
      before do
        SubscriptionManager.new(user).unsubscribe(subject)
      end

      context 'and billing_date has passed' do
        it
      end

      context 'and billing_date has not become' do
        its(:expired?) { should eq(true) }
      end
    end

    context 'when not removed' do
      context 'and billing_date has passed' do
        it
      end

      context 'and billing_date has not become' do
        its(:expired?) { should eq(false) }
      end
    end
  end

  describe '#canceled_at' do
    pending 'TODO(JD): missing specs'
  end
end

