require 'spec_helper'

describe Queries::Elastic::Users do
  subject { described_class.new }

  describe '#search' do
    subject { described_class.new.search('Test') }

    context 'multiple users' do
      let!(:first_user) { create(:user, full_name: 'Test', hidden: false) }
      let!(:second_user) { create(:user, full_name: 'Test', hidden: false) }

      before { update_index }

      it { expect(subject.records).to eq([first_user, second_user]) }
    end
  end

  describe '#delete' do
    let!(:first_user) { create(:user, full_name: 'Test') }
    let!(:second_user) { create(:user, full_name: 'Test') }

    before do
      update_index
      subject.delete
    end

    it { expect(subject.search('Test').records).to eq([]) }
  end

  describe '#client' do
    it { expect(subject.client).to be_a(Elasticpal::Client) }
  end

  describe '#index' do
    it { expect(subject.index).to eq('users') }
  end

  describe '#model' do
    it { expect(subject.model).to eq(User) }
  end

  describe '#scope' do
    it { expect(subject.scope).to eq(User) }
  end

  describe '#type' do
    it { expect(subject.type).to eq('default') }
  end
end
