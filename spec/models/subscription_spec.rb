require 'spec_helper'

describe Subscription do
  let(:user) { create_user }
  let(:target_user) { create_profile email: 'target@user.com' }

  subject { SubscriptionManager.new(user).subscribe_to(target_user) }

  before { StripeMock.start }
  after { StripeMock.stop }

  describe '#notify_about_payment_failure?' do
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
end
