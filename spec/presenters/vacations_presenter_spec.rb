describe VacationsPresenter do
  let(:profile_owner) { create(:user, :profile_owner, email: 'profile@owner.com') }

  subject(:presenter) { described_class.new(user: profile_owner) }
  subject { presenter.collection.first }

  context 'Vacation not happens' do
    describe '#collection' do
      it { expect(presenter.collection).to eq([]) }
    end
  end

  context 'Profile owner goes to vacation' do
    let(:start_vacation_date)  { profile_owner.events.where(action: 'vacation_mode_enabled').first.created_at }

    before do
      UserProfileManager.new(profile_owner).enable_vacation_mode(reason: 'No reason')
    end

    context 'Vacation starts but not ends' do
      describe '#start_date' do
        it { expect(subject.start_date).to eq(start_vacation_date.to_date.to_s(:long)) }
      end

      describe '#finish_date' do
        it { expect(subject.finish_date).to be_nil }
      end

      describe '#length' do
        it { expect(subject.length).to be_nil }
      end
    end

    context 'Vacation ends' do
      let(:finish_vacation_date) { profile_owner.events.where(action: 'vacation_mode_disabled').first.created_at }

      before do
        UserProfileManager.new(profile_owner).disable_vacation_mode
      end

      describe '#start_date' do
        it { expect(subject.start_date).to eq(start_vacation_date.to_date.to_s(:long)) }
      end

      describe '#finish_date' do
        it { expect(subject.finish_date).to eq(finish_vacation_date.to_date.to_s(:long)) }
      end

      describe '#length' do
        it { expect(subject.length).to eq(finish_vacation_date - start_vacation_date) }
      end
    end
  end
end
