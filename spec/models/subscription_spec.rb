describe Subscription do
  let(:user) { create :user, :with_cc }
  let(:target_user) { create :user, :profile_owner }

  subject { SubscriptionManager.new(subscriber: user).subscribe_to(target_user) }

  describe '.on_charge' do
    before { StripeMock.start }
    after { StripeMock.stop }

    before do
      UserProfileManager.new(user).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
      user.reload
    end

    let!(:unpaid_subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(target_user) }
    let!(:paid_subscription) { SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(create(:user, :profile_owner, email: 'another@one.com')) }
    let!(:invalid_subscription) do
      profile = create(:user, :profile_owner, email: 'invalid@one.com')

      SubscriptionManager.new(subscriber: user).subscribe_to(profile).tap do
        UserProfileManager.new(profile).delete_profile_page!
      end
    end

    it 'returns unpaid subscriptions' do
      expect(described_class.on_charge).to eq([unpaid_subscription])
    end
  end

  describe '.to_charge' do
    subject { described_class.to_charge }

    let(:subscription) { create :subscription, {user: user, target_user: target_user}.merge(attributes) }
    let(:attributes) { {} }
    let!(:payment) { create :payment, user: user }

    context 'never paid' do
      let!(:payment) {}
      it { expect(subject).not_to include(subscription) }
    end

    context 'profile on vacation' do
      let(:target_user) { create :user, :profile_owner, vacation_enabled: true }
      it { expect(subject).not_to include(subscription) }
    end

    context 'removed subscription' do
      let(:attributes) { {removed: true} }
      it { expect(subject).not_to include(subscription) }
    end

    context 'fake subscription' do
      let(:attributes) { {charged_at: nil, fake: true} }
      it { expect(subject).not_to include(subscription) }
    end

    context 'deleted subscription' do
      let(:subscription) { create :subscription, :deleted, {user: user, target_user: target_user}.merge(attributes) }
      it { expect(subject).not_to include(subscription) }
    end

    context 'paid' do
      context 'recently' do
        let(:attributes) { {charged_at: 2.days.ago } }
        it { expect(subject).not_to include(subscription) }
      end

      context 'in the previous billing cycle' do
        let(:attributes) { {charged_at: 2.months.ago} }
        it { expect(subject).to include(subscription) }
      end

      context 'paid on January 31', freeze: 'February 29, 2016' do
        let(:attributes) { {charged_at: Date.new(2016, 1, 31)} }
        it { expect(subject).to include(subscription) }
      end

      context 'paid on January 31', freeze: 'February 28, 2016' do
        let(:attributes) { {charged_at: Date.new(2016, 1, 31)} }
        it { expect(subject).not_to include(subscription) }
      end

      context 'paid on January 30', freeze: 'February 29, 2016' do
        let(:attributes) { {charged_at: Date.new(2016, 1, 30)} }
        it { expect(subject).to include(subscription) }
      end

      context 'paid on January 29', freeze: 'February 29, 2016' do
        let(:attributes) { {charged_at: Date.new(2016, 1, 29)} }
        it { expect(subject).to include(subscription) }
      end

      context 'paid on January 28', freeze: 'February 29, 2016' do
        let(:attributes) { {charged_at: Date.new(2016, 1, 28)} }
        it { expect(subject).to include(subscription) }
      end
    end
  end

  describe '.base_scope' do
    subject { described_class.base_scope }

    let!(:subscription) { create :subscription, user: user, target_user: target_user }
    let!(:deleted_subscription) { create :subscription, :deleted, user: user, target_user: target_user }

    it { expect(subject).to eq([subscription]) }
  end

  describe '#notify_about_payment_failure?' do
    before { StripeMock.start }
    after { StripeMock.stop }

    context 'subscription is paid' do
      before do
        PaymentManager.new(user: user).pay_for(subject)
      end

      it 'notifies user about payment failure' do
        expect(subject.notify_about_payment_failure?).to eq(true)
      end

    end

    context 'payment failed' do
      before do
        StripeMock.prepare_card_error(:card_declined)
        PaymentManager.new(user: user).pay_for(subject)
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

      context 'five days later (last try)' do
        it 'does notify' do
          Timecop.freeze(5.days.from_now) do
            expect(subject.notify_about_payment_failure?).to eq(true)
          end
        end
      end

      context 'any time later after last try' do
        it 'does notify' do
          Timecop.freeze(6.days.from_now) do
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

      context 'on 5th day' do
        specify do
          Timecop.freeze(5.days.from_now) do
            expect(subject.payment_attempts_expired?).to eq(false)
          end
        end
      end
    end

    context 'payment has failed' do
      before do
        StripeMock.prepare_card_error(:card_declined)
        PaymentManager.new(user: user).pay_for(subject)
      end

      specify do
        expect(subject.payment_attempts_expired?).to eq(false)
      end

      context 'on 5th day' do
        specify do
          Timecop.freeze(5.days.from_now) do
            expect(subject.payment_attempts_expired?).to eq(true)
          end
        end
      end

      context 'on any day later' do
        specify do
          Timecop.freeze(6.days.from_now) do
            expect(subject.payment_attempts_expired?).to eq(true)
          end
        end
      end
    end
  end

  describe '#canceled_at' do
    let(:removed_date) { DateTime.new(2014, 03, 03, 9, 8, 33) }
    let(:rejected_date) { DateTime.new(2014, 04, 13, 23, 58, 13) }

    context 'not rejected' do
      context 'and not removed' do
        it { expect(subject.canceled_at).to be_nil }
      end

      context 'and removed' do
        before do
          subject.removed = true
          subject.removed_at = removed_date
        end

        it { expect(subject.canceled_at).to eq(subject.removed_at) }
      end
    end

    context 'when rejected' do
      before do
        subject.rejected = true
        subject.rejected_at = rejected_date
      end

      context 'and not removed' do
        specify do
          expect(subject.canceled_at).to eq(subject.rejected_at)
          expect(subject.canceled_at).not_to be_nil
        end
      end

      context 'and removed' do
        before do
          subject.removed = true
          subject.removed_at = removed_date
        end

        it { expect(subject.canceled_at).to eq(subject.removed_at) }
      end
    end
  end

  describe '#actualize_cost!' do
    before do
      subject.update_attribute :cost, nil
    end

    specify do
      expect { subject.actualize_cost! }.to change { subject.cost }.from(nil).to(target_user.cost)
    end
  end

  describe '#billing_date', freeze: true do
    context 'paid subscription' do
      subject { create :subscription, charged_at: Time.zone.now }

      it 'becomes paid next month' do
        expect(subject.billing_date).to eq(Date.current + 30.days)
      end

      context 'paid on January 31', freeze: '17 February, 2016' do
        subject { create :subscription, charged_at: Date.new(2016, 1, 31) }

        it 'schedules payment on Feb 29' do
          expect(subject.billing_date).to eq(Date.new(2016, 2, 29))
        end
      end

      context 'paid on January 30', freeze: '17 February, 2016' do
        subject { create :subscription, charged_at: Date.new(2016, 1, 30) }

        it 'schedules payment on Feb 29' do
          expect(subject.billing_date).to eq(Date.new(2016, 2, 29))
        end
      end

      context 'paid on January 29', freeze: '17 February, 2016' do
        subject { create :subscription, charged_at: Date.new(2016, 1, 29) }

        it 'schedules payment on Feb 29' do
          expect(subject.billing_date).to eq(Date.new(2016, 1, 29) + 30.days)
        end
      end

      context 'paid on January 10', freeze: '17 February, 2016' do
        subject { create :subscription, charged_at: Date.new(2016, 1, 10) }

        it 'schedules payment on Feb 29' do
          expect(subject.billing_date).to eq(Date.new(2016, 1, 10) + 30.days)
        end
      end
    end

    context 'not paid' do
      subject { create :subscription, charged_at: nil }
      its(:billing_date) { is_expected.to eq(Date.current) }
    end

    context 'processing subscription' do
      subject { create :subscription, processing_payment: true  }

      it 'becomes paid today' do
        expect(subject.billing_date).to eq(Date.current)
      end
    end
  end

  describe '#paid?' do
    context 'paid' do
      subject { create :subscription, charged_at: Time.zone.now }
      its(:paid?) { is_expected.to eq(true) }
    end

    context 'never paid' do
      subject { create :subscription, charged_at: nil }
      its(:paid?) { is_expected.to eq(false) }
    end

    context 'paid but it is time to pay again' do
      subject { create :subscription, charged_at: 2.months.ago }
      its(:paid?) { is_expected.to eq(false) }

      context 'paid on January 31', freeze: 'February 29, 2016' do
        subject { create :subscription, charged_at: Date.new(2016, 1, 31) }
        its(:paid?) { is_expected.to eq(false) }
      end

      context 'paid on January 31', freeze: 'February 28, 2016' do
        subject { create :subscription, charged_at: Date.new(2016, 1, 31) }
        its(:paid?) { is_expected.to eq(true) }
      end

      context 'paid on January 30', freeze: 'February 29, 2016' do
        subject { create :subscription, charged_at: Date.new(2016, 1, 30) }
        its(:paid?) { is_expected.to eq(false) }
      end

      context 'paid on January 29', freeze: 'February 29, 2016' do
        subject { create :subscription, charged_at: Date.new(2016, 1, 29) }
        its(:paid?) { is_expected.to eq(false) }
      end

      context 'paid on January 28', freeze: 'February 29, 2016' do
        subject { create :subscription, charged_at: Date.new(2016, 1, 28) }
        its(:paid?) { is_expected.to eq(false) }
      end
    end

    context 'deleted' do
      subject { create :subscription, :deleted }
      its(:paid?) { is_expected.to eq(false) }
    end
  end

  describe '#payable?' do
    subject(:subscription) { create :subscription, {user: user, target_user: target_user}.merge(attributes) }

    let(:attributes) { {} }

    context 'not charged' do
      let(:attributes) { {charged_at: nil} }
      its(:payable?) { is_expected.to eq(true) }

      context 'subscriber locked' do
        let(:user) { create :user, :with_cc, locked: true, lock_type: 'billing' }
        its(:payable?) { is_expected.to eq(false) }
      end

      context 'profile owner locked' do
        context 'by billing' do
          let(:target_user) { create :user, :profile_owner, locked: true, lock_type: 'billing' }
          its(:payable?) { is_expected.to eq(true) }
        end

        context 'by account' do
          let(:target_user) { create :user, :profile_owner, locked: true, lock_type: 'account' }
          its(:payable?) { is_expected.to eq(false) }
        end

        context 'by tos' do
          let(:target_user) { create :user, :profile_owner, locked: true, lock_type: 'tos' }
          its(:payable?) { is_expected.to eq(false) }
        end
      end

      context 'profile owner deleted his profile page' do
        before { UserProfileManager.new(target_user).delete_profile_page! }
        its(:payable?) { is_expected.to eq(false) }
      end
    end

    context 'paid' do
      context 'recently' do
        let(:attributes) { {charged_at: 2.days.ago} }
        its(:payable?) { is_expected.to eq(false) }
      end

      context 'paid on January 31', freeze: 'February 29, 2016' do
        let(:attributes) { {charged_at: Date.new(2016, 1, 31)} }
        its(:payable?) { is_expected.to eq(true) }
      end

      context 'paid on January 31', freeze: 'February 28, 2016' do
        let(:attributes) { {charged_at: Date.new(2016, 1, 31)} }
        its(:payable?) { is_expected.to eq(false) }
      end

      context 'paid on January 30', freeze: 'February 29, 2016' do
        let(:attributes) { {charged_at: Date.new(2016, 1, 30)} }
        its(:payable?) { is_expected.to eq(true) }
      end

      context 'paid on January 29', freeze: 'February 29, 2016' do
        let(:attributes) { {charged_at: Date.new(2016, 1, 29)} }
        its(:payable?) { is_expected.to eq(true) }
      end

      context 'paid on January 28', freeze: 'February 29, 2016' do
        let(:attributes) { {charged_at: Date.new(2016, 1, 28)} }
        its(:payable?) { is_expected.to eq(true) }
      end
    end

    context 'deleted' do
      subject(:subscription) { create :subscription, :deleted, user: user, target_user: target_user }
      its(:payable?) { is_expected.to eq(false) }
    end
  end
end
