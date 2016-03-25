require 'spec_helper'

describe Dashboard::Admin::PaymentSourcesController, type: :controller do
  describe 'GET #index' do
    subject { get 'index' }

    context 'as an admin' do
      before { sign_in create_admin }
      it { is_expected.to be_success }

      context 'with country code' do
        subject { get 'index', source_country: 'US' }
        it { is_expected.to be_success }

        context 'empty country code' do
          subject { get 'index', source_country: 'empty' }
          it { is_expected.to be_success }
        end
      end

      context 'with profile' do
        subject { get 'index', profile: 'test' }
        it { is_expected.to be_success }
      end

      context 'with profile and country code' do
        subject { get 'index', profile: 'test', source_country: 'US' }
        it { is_expected.to be_success }
      end
    end

    context 'as a non admin' do
      before { sign_in create_user }
      it { is_expected.not_to be_success }
    end
  end
end
