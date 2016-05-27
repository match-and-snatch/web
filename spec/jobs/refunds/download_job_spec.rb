require 'spec_helper'

describe Refunds::DownloadJob do
  describe '#perform' do
    subject(:perform) { described_class.new.perform }

    before { StripeMock.start }
    after { StripeMock.stop }

    let(:user) { create :user, :with_cc }
    let(:target_user) { create :user, :profile_owner }
    let(:subscription) { create :subscription, user: user, target_user: target_user, charged_at: nil }
    let(:payment) { PaymentManager.new(user: user).pay_for(subscription).payments.last }
    let(:charge) { Stripe::Charge.retrieve(payment.stripe_charge_id) }
    let!(:refund) { charge.refunds.create(amount: 50) }

    it { expect { perform }.not_to raise_error }
    it { expect { perform }.to deliver_email(to: APP_CONFIG['emails']['reports'], subject: /Download Job/) }
    it { expect { perform }.to create_record(Refund).once.matching(amount: 50, charge: charge.id, payment_id: payment.id, user_id: user.id) }

    context 'perform at second time' do
      before { described_class.new.perform }

      it { expect { perform }.not_to create_record(Refund) }

      context 'with new refunds' do
        before { charge.refunds.create(amount: 20) }

        it { expect { perform }.to create_record(Refund).once.matching(amount: 20, charge: charge.id, payment_id: payment.id, user_id: user.id) }
      end
    end
  end
end
