require 'spec_helper'

describe Concerns::CostUpdatePerformer do
  let(:ids) { [] }
  let(:user1) { create(:user, :profile_owner) }
  let(:user2) { create(:user, :profile_owner) }
  let(:request1) { create :cost_change_request, new_cost: 85_00, user: user1 }
  let(:request2) { create :cost_change_request, new_cost: 85_00, user: user2 }

  subject(:performer) { described_class }

  describe '.approve_requests' do
    it { expect { performer.approve_requests }.to raise_error(BulkEmptySetError, /No requests selected/) }

    context 'ids are provided' do
      let(:ids) { [request1.id, request2.id] }

      it { expect { performer.approve_requests(ids) }.to change { request1.reload.approved? }.from(false).to(true) }
      it { expect { performer.approve_requests(ids) }.to change { request2.reload.approved? }.from(false).to(true) }

      it { expect { performer.approve_requests(ids) }.to change { user1.reload.cost }.from(4_00).to(85_00) }
      it { expect { performer.approve_requests(ids) }.to change { user2.reload.cost }.from(4_00).to(85_00) }
    end
  end

  describe '.reject_requests' do
    it { expect { performer.reject_requests }.to raise_error(BulkEmptySetError, /No requests selected/) }

    context 'ids are provided' do
      let(:ids) { [request1.id, request2.id] }

      it { expect { performer.reject_requests(ids) }.to change { request1.reload.rejected? }.from(false).to(true) }
      it { expect { performer.reject_requests(ids) }.to change { request2.reload.rejected? }.from(false).to(true) }

      it { expect { performer.reject_requests(ids) }.not_to change { user1.reload.cost }.from(4_00) }
      it { expect { performer.reject_requests(ids) }.not_to change { user2.reload.cost }.from(4_00) }
    end
  end
end
