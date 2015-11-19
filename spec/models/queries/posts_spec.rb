require 'spec_helper'

describe Queries::Posts do
  let(:user) { create(:user, :profile_owner) }

  subject { described_class.new(user: user, query: 'test') }

  describe '#results' do
    let!(:first_post) { create(:status_post, user: user, message: 'test') }
    let!(:second_post) { create(:status_post, user: user, message: 'test') }
    let!(:another_post) { create(:status_post, user: user, message: 'some another post') }
    let!(:hidden_post) { create(:status_post, user: user, message: 'hidden post', hidden: true) }

    before { update_index }

    context 'query is present' do
      it { expect(subject.results).to match_array([first_post, second_post]) }

      context 'tagged post' do
        pending
      end
    end

    context 'blank query' do
      subject { described_class.new(user: user, current_user: user) }

      it { expect(subject.results).to match_array([first_post, second_post, another_post]) }

      context 'include hidden' do
        let(:another_user) { create(:user) }

        subject { described_class.new(user: user, current_user: another_user) }

        it { expect(subject.results).to match_array([first_post, second_post, another_post, hidden_post]) }
      end
    end
  end

  describe '#last_post_id' do
    pending
  end

  describe '#user_input?' do
    it { expect(described_class.new.user_input?).to eq(false) }
    it { expect(described_class.new(query: 'test').user_input?).to eq(true) }
    it { expect(described_class.new(page: 2).user_input?).to eq(false) }
    it { expect(described_class.new(query: 'test', page: 2).user_input?).to eq(false) }
  end
end
