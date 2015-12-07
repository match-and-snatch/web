require 'spec_helper'

describe Contribution do
  describe '.to_charge' do
    subject { described_class.to_charge }

    let(:contribution_to_user_with_profile_page) { create :contribution, recurring: true, target_user: create(:user, :profile_owner), updated_at: 100.years.ago }
    let(:contribution_to_user_without_profile_page) { create :contribution, recurring: true, target_user: create(:user), updated_at: 100.years.ago }

    it { is_expected.to include(contribution_to_user_with_profile_page) }
    it { is_expected.not_to include(contribution_to_user_without_profile_page) }
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
          let(:user) { create :user, :with_cc, locked: true, lock_reason: :billing }
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
          let(:target_user) { create :user, :profile_owner, locked: true, lock_reason: lock_reason, subscribers_count: 5, contributions_enabled: true }

          context 'profile billing lock' do
            let(:lock_reason) { 'billing' }
            its(:recurring_performable?) { is_expected.to eq(true) }
          end

          context 'profile tos lock' do
            let(:lock_reason) { 'tos' }
            its(:recurring_performable?) { is_expected.to eq(false) }
          end

          context 'profile account lock' do
            let(:lock_reason) { 'account' }
            its(:recurring_performable?) { is_expected.to eq(false) }
          end
        end
      end
    end
  end
end
