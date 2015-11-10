require 'spec_helper'

describe Queries::Users do
  let(:performer) { create(:user, email: 'performer@gmail.com') }
  let!(:first_user) { create(:user, :profile_owner, email: 'szinin@gmail.com', full_name: 'Sergei', profile_name: 'Sergei Zinin') }
  let!(:second_user) { create(:user, :with_cc, email: 'spopov@gmail.com', full_name: 'Slava') }
  let(:query) { 'szinin@gmail.com' }

  subject { described_class.new(user: performer, query: query) }

  before { update_index }

  describe '#grouped_by_first_letter' do
    it { expect(subject.grouped_by_first_letter).to include({ 'S' => [first_user] }) }
  end

  describe '#by_first_letter' do
    it { expect(subject.by_first_letter).to eq([first_user]) }
  end

  describe '#by_name' do
    let(:query) { 'sergei' }

    it { expect(subject.by_name).to eq([first_user]) }
  end

  describe '#by_admin_fields' do
    context 'query is a stripe user id' do
      let(:query) { second_user.stripe_user_id }

      it { expect(subject.by_admin_fields).to eq([second_user]) }
    end

    context 'query is an email' do
      it { expect(subject.by_admin_fields).to eq([first_user]) }
    end

    context 'query is an id' do
      let(:query) { second_user.id }

      it { expect(subject.by_admin_fields).to eq([second_user]) }
    end

    context 'regular query' do
      let(:query) { 'Slava' }

      it { expect(subject.by_admin_fields).to eq([second_user]) }
    end
  end

  describe '#potential_partners' do
    pending
  end

  describe '#profile_owners_by_text' do
    context 'empty query' do
      let(:query) { '' }

      it { expect(subject.profile_owners_by_text).to eq([]) }
    end

    context 'short query' do
      let(:query) { 's' }

      it { expect(subject.profile_owners_by_text).to eq([]) }
    end

    context 'normal query' do
      let(:query) { 'Sergei' }

      it { expect(subject.profile_owners_by_text).to eq([first_user]) }
    end
  end

  describe '#results' do
    it { expect(subject.results).to eql([first_user]) }
  end

  describe '#by_email' do
    it { expect(subject.by_email).to eql([first_user]) }
  end

  describe '#emails' do
    it { expect(subject.emails).to eql(['szinin@gmail.com']) }
  end
end
