describe Users::PopulateBillingAddressCountryJob do
  describe '#perform' do
    subject(:perform) { described_class.new.perform }

    let(:cc_token) do
      StripeMock.generate_card_token(address_city: 'Pasadena',
                                     address_country: 'US',
                                     address_line1: '3690 New Haven Rd',
                                     address_line2: '',
                                     address_state: 'California',
                                     address_zip: '91107')
    end
    let(:customer) { Stripe::Customer.create(email: 'asd@asd.com', source: cc_token) }
    let(:user_with_customer) { create :user, :with_cc, stripe_user_id: customer.id, billing_address_country: nil }
    let!(:user_without_customer) { create(:user, :with_cc, billing_address_country: nil) }
    let!(:user) { create(:user, billing_address_country: nil) }

    before { StripeMock.start }
    after { StripeMock.stop }

    it { expect { perform }.not_to raise_error }
    it { expect { perform }.not_to change { user.reload.billing_address_country }.from(nil) }
    it { expect { perform }.not_to change { user_without_customer.reload.billing_address_country }.from(nil) }

    it 'sets country' do
      expect { perform }.to change { user_with_customer.reload.billing_address_country }.from(nil).to('US')
    end
  end
end
