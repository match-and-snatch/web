require 'spec_helper'

describe CostChangeRequestManager do
  let(:user) { create_profile(email: 'profile@lol.com') }
  let(:request) { described_class.new(user: user).create(new_cost: 10) }

  subject { described_class.new(request: request) }

  describe '#create' do
    it { expect(described_class.new(user: user).create(new_cost: 10)).to be_a CostChangeRequest }

    it do
      expect(ProfilesMailer).to receive(:cost_change_request).and_return(double('mailer').as_null_object)
      described_class.new(user: user).create(new_cost: 10)
    end
  end

  describe '#reject' do
    it { expect { subject.reject }.to change { request.rejected }.from(false).to(true) }
    it { expect { subject.reject }.to change { request.rejected_at }.from(nil) }
  end

  describe '#approve' do
    it { expect { subject.approve }.to change { request.approved }.from(false).to(true) }
    it { expect { subject.approve }.to change { request.approved_at }.from(nil) }
  end

  describe '#change_cost' do
    it { expect { subject.change_cost }.to change { request.performed }.from(false).to(true) }
    it { expect { subject.change_cost }.to change { request.performed_at }.from(nil) }
  end
end
