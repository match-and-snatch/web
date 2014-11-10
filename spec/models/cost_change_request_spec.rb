require 'spec_helper'

describe CostChangeRequest do
  let(:user) { create_profile(email: 'profile@lol.com') }

  subject { described_class.create!(user: user, old_cost: user.cost, new_cost: 800) }

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
end
