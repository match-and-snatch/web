require 'spec_helper'

describe DuplicatesPresenter do
  context 'empty set' do
    its(:collection) { should be_a Hash }
  end

  context 'no duplicates' do
    before do
      create_user email: 'no@duplicates.com'
    end

    its(:collection) { should be_empty }
  end

  context 'with duplicates' do
    before do
      create_user email: 'no@duplicates.com'
    end

    let!(:first_duplicate) { create_user email: 'duplicate@gmail.com' }
    let!(:second_duplicate) { create_user email: 'DUPLICATE_@gmaiL.com' }

    before do
      second_duplicate.update_attribute(:email, 'duplicate@gmail.com')
      second_duplicate.reload
    end

    its(:collection) { should == {'duplicate@gmail.com' => [first_duplicate, second_duplicate]} }
  end
end
