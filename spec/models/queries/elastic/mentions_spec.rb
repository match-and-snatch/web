require 'spec_helper'

describe Queries::Elastic::Mentions do
  let(:profile_owner) { create :user, :profile_owner, profile_name: 'Andy Dean' }
  let(:subscriber) { create :user, :with_cc, full_name: 'Dmitry' }

  before do
    SubscriptionManager.new(subscriber: subscriber).subscribe_to(profile_owner)
  end

  before { update_index }

  context 'without profile owner id' do
    subject(:results) { described_class.search('Dmitry').records }
    it { is_expected.to eq([subscriber]) }

    context 'searching for profile owner' do
      subject(:results) { described_class.search('Andy').records }
      it { is_expected.to eq([profile_owner]) }
    end

    context 'not matching' do
      subject(:results) { described_class.search('Dimka').records }
      it { is_expected.to be_empty }
    end
  end

  context 'with profile owner id scope' do
    subject(:results) { described_class.search('Dmitry', profile_id: profile_owner.id).records }
    it { is_expected.to eq([subscriber]) }

    context 'searching for profile owner' do
      subject(:results) { described_class.search('Andy', profile_id: profile_owner.id).records }
      it { is_expected.to eq([profile_owner]) }
    end

    context 'not matching' do
      subject(:results) { described_class.search('Dimka', profile_id: profile_owner.id).records }
      it { is_expected.to be_empty }
    end

    context 'invalid profile id' do
      subject(:results) { described_class.search('Dmitry', profile_id: 999).records }
      it { is_expected.to be_empty }
    end

    context 'another profile id' do
      let(:another_profile_owner) { create :user, :profile_owner, profile_name: 'Andy Dean' }
      let(:another_subscriber) { create :user, :with_cc, full_name: 'Dmitry' }

      before do
        SubscriptionManager.new(subscriber: another_subscriber).subscribe_to(another_profile_owner)
      end

      before { update_index }

      it { is_expected.to eq([subscriber]) }

      context 'searching for profile owner' do
        subject(:results) { described_class.search('Andy', profile_id: profile_owner.id).records }
        it { is_expected.to eq([profile_owner]) }
      end
    end
  end
end
