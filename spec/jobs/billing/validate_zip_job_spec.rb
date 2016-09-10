require 'spec_helper'

RSpec.describe Billing::ValidateZipJob do
  subject(:perform) { described_class.new.perform }

  let(:user) { create :user, user_attributes }
  let(:user_attributes) do
    {
      stripe_card_id: 'set',
      billing_address_city: 'Warner robins',
      billing_address_zip: '31088',
      billing_zip_check_failed: nil
    }
  end

  it { expect { perform }.to deliver_email(to: APP_CONFIG['emails']['reports'], subject: /Validate Zip Job/) }
  it { expect { perform }.to change { user.reload.billing_zip_check_failed }.to(false) }

  context 'user without CC' do
    let(:user_attributes) do
      {
        billing_address_city: 'Warner robins',
        billing_address_zip: '31088',
        billing_zip_check_failed: nil
      }
    end

    it { expect { perform }.not_to change { user.reload.billing_zip_check_failed } }
  end

  context 'user has already been checked' do
    context 'user zip check failed' do
      let(:user) { create :user, user_attributes.merge(billing_address_zip: '660125', billing_zip_check_failed: true) }
      it { expect { perform }.not_to change { user.reload.billing_zip_check_failed }.from(true) }
    end

    context 'user zip check succeed' do
      let(:user) { create :user, user_attributes.merge(billing_address_zip: '660125', billing_zip_check_failed: false) }
      it { expect { perform }.not_to change { user.reload.billing_zip_check_failed }.from(false) }
    end
  end

  context 'zip does not match city' do
    context 'no city found by zip' do
      let(:user_attributes) do
        {
          stripe_card_id: 'set',
          billing_address_city: 'Warner robins',
          billing_address_zip: '660125',
          billing_zip_check_failed: nil
        }
      end

      it { expect { perform }.to change { user.reload.billing_zip_check_failed }.to(true) }
    end

    context 'different city specified' do
      let(:user_attributes) do
        {
          stripe_card_id: 'set',
          billing_address_city: 'Los Angeles',
          billing_address_zip: '31088',
          billing_zip_check_failed: nil
        }
      end

      it { expect { perform }.to change { user.reload.billing_zip_check_failed }.to(true) }
    end
  end
end
