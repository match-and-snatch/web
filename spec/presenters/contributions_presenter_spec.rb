describe ContributionsPresenter do
  let(:target_user) { create(:user, :profile_owner) }
  let(:user) { create(:user) }
  let(:contribute) { create(:contribution, target_user: target_user, user: user) }
  let(:current_year) { Time.zone.now.year }

  subject { described_class.new(user: target_user) }

  describe '#any?' do
    context 'no contributions' do
      it { expect(subject.any?).to eq(false) }
    end

    context 'with contributions' do
      before { contribute }

      it { expect(subject.any?).to eq(true) }
    end
  end

  describe '#any_for_year?' do
    context 'no contributions' do
      it { expect(subject.any_for_year?).to eq(false) }
    end

    context 'with contributions' do
      before { contribute }

      it { expect(subject.any_for_year?).to eq(true) }
    end

    context 'with past year contributions' do
      let(:year) { 2007 }

      subject { described_class.new(user: target_user, year: year) }

      before { Timecop.freeze(Time.new(year)) { contribute } }

      it { expect(subject.any_for_year?).to eq(true) }
    end
  end

  describe '#contribution_years' do
    context 'no contributions' do
      it { expect(subject.contribution_years).to eq([current_year]) }
    end

    context 'with previous year contributions' do
      let(:year) { 2007 }

      before  do
        Timecop.freeze(Time.new(year) + 2.days) do # + 2 days because running in KRAT it is 31 Dec for PST
          contribute
        end
      end

      it { expect(subject.contribution_years).to eq([year, current_year]) }
    end
  end

  describe '#contributions' do
    context 'no contributions' do
      it { expect(subject.contributions).to eq([]) }
    end

    context 'with contributions' do
      let(:year) { 2007 }
      let!(:contribution) { create(:contribution, target_user: target_user, user: user) }
      let!(:past_contribution) { Timecop.freeze(Time.new(year)) { create(:contribution, target_user: target_user, user: user) } }

      it { expect(subject.contributions).to eq([contribution]) }

      context 'filtered by year' do
        subject { described_class.new(user: target_user, year: year) }

        it { expect(subject.contributions).to eq([past_contribution]) }
      end
    end
  end
end
