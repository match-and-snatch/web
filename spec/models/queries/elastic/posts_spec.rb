require 'spec_helper'

describe Queries::Elastic::Posts do
  subject { described_class.new }

  describe '#search' do
    subject { described_class.new.search(fulltext_query: 'Test') }

    context 'multiple posts' do
      let(:first_user) { create(:user, :profile_owner) }
      let(:second_user) { create(:user, :profile_owner) }
      let!(:first_post)  { create(:status_post, user: first_user,  message: 'Test') }
      let!(:second_post) { create(:status_post, user: second_user, message: 'Test') }
      let!(:third_post)  { create(:status_post, user: second_user, message: 'Test', hidden: true) }


      before { update_index }

      it { expect(subject.records).to match_array([first_post, second_post]) }

      context 'filtered by user_id' do
        subject { described_class.new.search(fulltext_query: 'Test', user_id: first_user.id) }

        it { expect(subject.records).to eq([first_post]) }
      end

      context 'include hidden' do
        subject { described_class.new.search(fulltext_query: 'Test', include_hidden: true) }

        it { expect(subject.records).to match_array([first_post, second_post, third_post]) }
      end
    end

    context 'title as query' do
      let!(:first_post) { create(:status_post, title: 'Test', message: 'Message') }
      let!(:second_post) { create(:status_post, title: 'Title', message: 'Test') }

      before { update_index }

      it { expect(subject.records).to eq([first_post, second_post]) }
    end

    context 'ranked with created at' do
      let!(:first_post) { create(:status_post, title: 'Test', message: 'Message') }
      let!(:second_post) { Timecop.freeze(1.days.from_now) { create(:status_post, title: 'Title', message: 'Test') } }

      before { update_index }

      it { expect(subject.records).to eq([second_post, first_post]) }
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
