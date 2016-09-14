RSpec.describe CardsDuplicatesPresenter do
  context 'empty set' do
    its(:collection) { is_expected.to be_a Hash }
  end

  context 'no duplicates' do
    before { create(:user, :with_cc) }

    its(:collection) { is_expected.to be_empty }
  end

  context 'with duplicates' do
    before { create(:user, :with_cc) }

    let!(:first_duplicate) { create(:user, :with_cc) }
    let!(:second_duplicate) { create(:user, :with_cc) }

    before do
      second_duplicate.update_attribute(:stripe_card_fingerprint, first_duplicate.stripe_card_fingerprint)
      second_duplicate.reload
    end

    its(:collection) { is_expected.to eq({first_duplicate.stripe_card_fingerprint => [second_duplicate, first_duplicate]}) }
  end
end
