require 'spec_helper'

describe CostChangeRequest do
  let(:user) { create(:user, :profile_owner) }

  subject { create(:cost_change_request, user: user, old_cost: user.cost, new_cost: 800) }

  describe '#reject!' do
    it { expect { subject.reject! }.to change { subject.rejected }.from(false).to(true) }
    it { expect { subject.reject! }.to change { subject.rejected_at }.from(nil) }
  end

  describe '#approve!' do
    it { expect { subject.approve! }.to change { subject.approved }.from(false).to(true) }
    it { expect { subject.approve! }.to change { subject.approved_at }.from(nil) }
  end

  describe '#perform!' do
    it { expect { subject.perform! }.to change { subject.performed }.from(false).to(true) }
    it { expect { subject.perform! }.to change { subject.performed_at }.from(nil) }
  end

  describe '#initial?' do
    context 'user just applied' do
      subject { create(:cost_change_request, user: user, old_cost: nil) }
      its(:initial?) { is_expected.to eq(true) }
    end

    context 'user changes the existing cost' do
      subject { create(:cost_change_request, user: user, old_cost: 1000) }
      its(:initial?) { is_expected.to eq(false) }
    end
  end

  describe '#completes_profile?' do
    context 'profile owner' do
      let(:user) { create(:user, :profile_owner) }

      context 'user just applied' do
        subject { create(:cost_change_request, user: user, old_cost: nil) }
        its(:completes_profile?) { is_expected.to eq(true) }
      end

      context 'user changes the existing cost' do
        subject { create(:cost_change_request, user: user, old_cost: 1000) }
        its(:completes_profile?) { is_expected.to eq(false) }
      end

      context 'not finished profile' do
        let(:user) { create(:user, :profile_owner, profile_name: nil) }
        subject { create(:cost_change_request, user: user, old_cost: nil) }
        its(:completes_profile?) { is_expected.to eq(false) }
      end
    end

    context 'subscriber' do
      let(:user) { create(:subscriber) }

      context 'user just applied' do
        subject { create(:cost_change_request, user: user, old_cost: nil) }
        its(:completes_profile?) { is_expected.to eq(false) }
      end

      context 'user changes the existing cost' do
        subject { create(:cost_change_request, user: user, old_cost: 1000) }
        its(:completes_profile?) { is_expected.to eq(false) }
      end
    end
  end
end
