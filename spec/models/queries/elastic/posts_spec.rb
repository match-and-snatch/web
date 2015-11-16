require 'spec_helper'

describe Queries::Elastic::Posts do
  subject { described_class.new }

  describe '#search' do
    subject { described_class.new.search(fulltext_query: 'Test') }

    context 'multiple users' do
      let!(:first_post) { create(:status_post, message: 'Test') }
      let!(:second_post) { create(:status_post, message: 'Test') }

      before { update_index }

      it { expect(subject.records).to match_array([first_post, second_post]) }
    end
  end

  describe '#delete' do
    let!(:first_post) { create(:status_post, message: 'Test') }
    let!(:second_post) { create(:status_post, message: 'Test') }

    before do
      update_index
      subject.delete
      refresh_index
    end

    it { expect(subject.search(fulltext_query: 'Test').records).to eq([]) }
  end

  describe '#client' do
    it { expect(subject.client).to be_a(Elasticpal::Client) }
  end

  describe '#index' do
    it { expect(subject.index).to eq('posts') }
  end

  describe '#model' do
    it { expect(subject.model).to eq(Post) }
  end

  describe '#scope' do
    it { expect(subject.scope).to eq(Post) }
  end

  describe '#type' do
    it { expect(subject.type).to eq('default') }
  end
end
