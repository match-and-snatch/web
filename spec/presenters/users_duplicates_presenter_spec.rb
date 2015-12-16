require 'spec_helper'

describe UsersDuplicatesPresenter do
  context 'empty set' do
    its(:collection) { should be_a Hash }
  end

  context 'no duplicates' do
    before { create(:user, email: 'no@duplicates.com') }

    its(:collection) { should be_empty }
  end

  context 'with duplicates' do
    before { create(:user, email: 'no@duplicates.com') }

    let!(:first_duplicate) { create(:user, email: 'duplicate@gmail.com') }
    let!(:second_duplicate) { create(:user, email: 'DUPLICATE_@gmaiL.com') }

    before do
      second_duplicate.update_attribute(:email, 'duplicate@gmail.com')
      second_duplicate.reload
    end

    its(:collection) { should == {'duplicate@gmail.com' => [first_duplicate, second_duplicate]} }
  end
end
