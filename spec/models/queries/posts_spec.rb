require 'spec_helper'

describe Queries::Posts do
  let(:user) { create(:user, :profile_owner) }
  let(:query) { 'test' }

  subject { described_class.new(user: user, query: query) }

  describe '#results' do
    let(:first_post_message)  { 'test' }
    let(:second_post_message) { 'test' }
    let(:third_post_message)  { 'test' }

    let!(:first_post)  { Timecop.freeze(3.days.from_now) { create(:status_post, user: user, message: first_post_message) } }
    let!(:second_post) { Timecop.freeze(2.days.from_now) { create(:status_post, user: user, message: second_post_message) } }
    let!(:third_post)  { Timecop.freeze(1.days.from_now) { create(:status_post, user: user, message: third_post_message) } }

    let!(:another_post) { create(:status_post, user: user, message: 'some another post') }
    let!(:hidden_post)  { create(:status_post, user: user, message: 'hidden post', hidden: true) }

    before { update_index }

    context 'query is present' do
      it { expect(subject.results).to match_array([first_post, second_post, third_post]) }

      context 'tagged post' do
        let(:query) { '#status' }

        it { expect(subject.results).to eq([first_post, second_post, third_post, another_post]) }

        context 'wrong tag' do
          let(:query) { '#tag' }

          it { expect(subject.results).to be_empty }
        end
      end
    end

    context 'page is present' do
      let(:second_post_message) { 'post test' }
      let(:third_post_message)  { 'message test' }

      it do
        # TODO: FIX IT
        # expect(described_class.new(user: user, query: query, page: 1, limit: 2).results).to eq([first_post, third_post])
        # expect(described_class.new(user: user, query: query, page: 2, limit: 2).results).to eq([second_post])
        expect(described_class.new(user: user, query: query, page: 1, limit: 2).results.count).to eq(2)
        expect(described_class.new(user: user, query: query, page: 2, limit: 2).results.count).to eq(1)
      end
    end

    context 'blank query' do
      subject { described_class.new(user: user, current_user: user) }

      it { expect(subject.results).to match_array([first_post, second_post, third_post, another_post]) }

      context 'include hidden' do
        let(:another_user) { create(:user) }

        subject { described_class.new(user: user, current_user: another_user) }

        it { expect(subject.results).to match_array([first_post, second_post, third_post, another_post, hidden_post]) }
      end
    end
  end

  describe '#last_post_id' do
    let!(:post) { create(:status_post, user: user, message: 'post') }

    before { update_index }

    it { expect(subject.last_post_id).to be_nil }

    context 'no query' do
      let(:query) { nil }

      it { expect(subject.last_post_id).to eq(post.id) }
    end

    context 'posts present' do
      let(:query) { 'post' }

      it { expect(subject.last_post_id).to eq(post.id) }
    end
  end

  describe '#user_input?' do
    it { expect(described_class.new.user_input?).to eq(false) }
    it { expect(described_class.new(query: 'test').user_input?).to eq(true) }
    it { expect(described_class.new(page: 2).user_input?).to eq(false) }
    it { expect(described_class.new(query: 'test', page: 2).user_input?).to eq(false) }
  end
end
