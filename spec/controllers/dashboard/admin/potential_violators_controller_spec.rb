require 'spec_helper'

describe Dashboard::Admin::PotentialViolatorsController, type: :controller do
  describe 'GET #index' do
    subject { get 'index' }

    before { sign_in current_user }

    let(:current_user) { create :user, :admin }

    it { is_expected.to be_success }

    context 'as a non admin' do
      let(:current_user) { create :user }

      it { is_expected.not_to be_success }
    end
  end
end
