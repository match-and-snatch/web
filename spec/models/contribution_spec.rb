describe Contribution do
  describe '.to_charge' do
    subject { described_class.to_charge }

    let(:contributor) { create(:user) }
    let(:user) { create(:user) }
    let(:profile_owner) { create(:user, :profile_owner, subscribers_count: 5) }

    let(:contribution_to_user_without_profile_page) { create :contribution, user: contributor, recurring: true, target_user: user, updated_at: 100.years.ago }
    let(:contribution_to_user_with_profile_page) { create :contribution, user: contributor, recurring: true, target_user: profile_owner, updated_at: 100.years.ago }

    it { is_expected.to include(contribution_to_user_with_profile_page) }
    it { is_expected.not_to include(contribution_to_user_without_profile_page) }

    context 'locked contributor' do
      let(:contributor) { create(:user, locked: true) }

      it { is_expected.not_to include(contribution_to_user_with_profile_page) }
      it { is_expected.not_to include(contribution_to_user_without_profile_page) }
    end

    context 'profile owner has 4 or less subscribers' do
      let(:profile_owner) { create(:user, :profile_owner, subscribers_count: 4) }
      it { is_expected.not_to include(contribution_to_user_with_profile_page) }

      context do
        let(:profile_owner) { create(:user, :profile_owner, subscribers_count: 3) }
        it { is_expected.not_to include(contribution_to_user_with_profile_page) }
      end
    end

    context 'profile owner with disabled contributions' do
      let(:profile_owner) { create(:user, :profile_owner, subscribers_count: 5, contributions_enabled: false) }
      it { is_expected.not_to include(contribution_to_user_with_profile_page) }
    end

    context 'profile owner is locked' do
      let(:profile_owner) { create(:user, :profile_owner, subscribers_count: 5, locked: true) }
      it { is_expected.not_to include(contribution_to_user_with_profile_page) }

      context 'by tos' do
        let(:profile_owner) { create(:user, :profile_owner, subscribers_count: 5, locked: true, lock_type: 'tos') }
        it { is_expected.not_to include(contribution_to_user_with_profile_page) }
      end

      context 'by account' do
        let(:profile_owner) { create(:user, :profile_owner, subscribers_count: 5, locked: true, lock_type: 'account') }
        it { is_expected.not_to include(contribution_to_user_with_profile_page) }
      end

      context 'by billing' do
        let(:profile_owner) { create(:user, :profile_owner, subscribers_count: 5, locked: true, lock_type: 'billing') }
        it { is_expected.to include(contribution_to_user_with_profile_page) }
      end
    end

    context 'cancelled contribution' do
      let(:cancelled_contribution) { create(:contribution, :cancelled, recurring: true, updated_at: 100.years.ago) }
      it { is_expected.not_to include(cancelled_contribution) }
    end
  end

  describe '.active' do
    subject { described_class.active }
    let(:contribution) { create(:contribution) }
    it { is_expected.not_to include(contribution) }

    context 'recurring contribution present' do
      let(:contribution) { create(:contribution, recurring: true) }
      it { is_expected.to include(contribution) }

      context 'cancelled contribution present' do
        let(:contribution) { create(:contribution, :cancelled, recurring: true) }
        it { is_expected.not_to include(contribution) }
      end
    end
  end

  describe '#recurring_performable?' do
    let(:user) { create :user, :with_cc }
    let(:target_user) { create :user, :profile_owner, subscribers_count: 5, contributions_enabled: true }
    subject(:contribution) { create :contribution, {user: user, target_user: target_user}.merge(attributes) }

    context 'recurring' do
      let(:attributes) { {recurring: true} }
      its(:recurring_performable?) { is_expected.to eq(false) }

      context '1 month since last charge not passed yet' do
        before do
          create :contribution, parent: contribution, created_at: 27.days.ago
        end

        its(:recurring_performable?) { is_expected.to eq(false) }
      end

      context '1 month since last charge' do
        before do
          create :contribution, parent: contribution, created_at: 32.days.ago
        end

        its(:recurring_performable?) { is_expected.to eq(true) }

        context 'user locked' do
          let(:user) { create :user, :with_cc, locked: true, lock_type: :billing }
          its(:recurring_performable?) { is_expected.to eq(false) }
        end

        context 'target user contributions are not enabled' do
          let(:target_user) { create :user, :profile_owner, subscribers_count: 5, contributions_enabled: false }
          its(:recurring_performable?) { is_expected.to eq(false) }
        end

        context 'not enough subscribers' do
          let(:target_user) { create :user, :profile_owner, subscribers_count: 3, contributions_enabled: true }
          its(:recurring_performable?) { is_expected.to eq(false) }
        end

        context 'target user locked' do
          let(:target_user) { create :user, :profile_owner, locked: true, lock_type: lock_type, subscribers_count: 5, contributions_enabled: true }

          context 'profile billing lock' do
            let(:lock_type) { 'billing' }
            its(:recurring_performable?) { is_expected.to eq(true) }
          end

          context 'profile tos lock' do
            let(:lock_type) { 'tos' }
            its(:recurring_performable?) { is_expected.to eq(false) }
          end

          context 'profile account lock' do
            let(:lock_type) { 'account' }
            its(:recurring_performable?) { is_expected.to eq(false) }
          end
        end

        context 'cancelled contribution' do
          let(:attributes) { {recurring: true, cancelled: true} }
          its(:recurring_performable?) { is_expected.to eq(false) }
        end
      end
    end
  end

  describe '#active?' do
    subject(:contribution) { create(:contribution) }
    its(:active?) { is_expected.to be_falsey }

    context 'recurring contribution' do
      subject(:contribution) { create(:contribution, recurring: true) }
      its(:active?) { is_expected.to be_truthy }

      context 'cancelled contribution' do
        subject(:contribution) { create(:contribution, :cancelled, recurring: true) }
        its(:active?) { is_expected.to be_falsey }
      end
    end
  end

  describe '#next_billing_date' do
    subject(:contribution) { create(:contribution, recurring: true) }
    its(:next_billing_date) { is_expected.to eq(contribution.created_at.next_month.to_date) }

    context 'has children' do
      subject(:contribution) { create(:contribution, recurring: true) }

      let(:child) { create(:contribution, parent: contribution) }
      its(:next_billing_date) { is_expected.to eq(child.created_at.next_month.to_date) }
    end

    context 'cancelled contribution' do
      subject(:contribution) { create(:contribution, :cancelled, recurring: true) }
      it { expect { contribution.next_billing_date }.to raise_error(ArgumentError) }
    end
  end

  describe '#will_repeat?' do
    let(:parent) { nil }
    subject(:contribution) { create(:contribution, parent: parent) }
    its(:will_repeat?) { is_expected.to be_falsey }

    context 'recurring contribution' do
      subject(:contribution) { create(:contribution, recurring: true) }
      its(:will_repeat?) { is_expected.to be_truthy }

      context 'cancelled contribution' do
        subject(:contribution) { create(:contribution, :cancelled, recurring: true) }
        its(:will_repeat?) { is_expected.to be_falsey }
      end
    end

    context 'has parent contribution' do
      let(:parent) { create(:contribution, recurring: true) }
      its(:will_repeat?) { is_expected.to be_truthy }

      context 'cancelled parent' do
        let(:parent) { create(:contribution, :cancelled, recurring: true) }
        its(:will_repeat?) { is_expected.to be_falsey }
      end
    end
  end
end
