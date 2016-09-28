describe Stripe::PopulateCustomerNameOnCardJob do
  describe '#perform' do
    subject(:perform) { described_class.new.perform }

    before { StripeMock.start }
    after { StripeMock.stop }

    let(:cc_token) do
      StripeMock.generate_card_token(address_city: 'Krasnoyarsk',
                                     address_country: 'Russia',
                                     address_line1: 'Lenina 1',
                                     address_line2: 'Mira 2',
                                     address_state: 'Kras',
                                     address_zip: '123456',
                                     name: nil)
    end
    let(:customer) do
      # Timecop.freeze Date.new(2016, 9, 24) do
      Stripe::Customer.create(email: 'dimon@kremlin.com', metadata: {full_name: 'Dimon Medvedef'}, source: cc_token, created: Time.new(2016, 9, 24).to_i)
      # end
    end
    let(:card_id) { customer.sources.first.id }

    it { expect { perform }.not_to raise_error }
    it { expect { perform }.to deliver_email(to: APP_CONFIG['emails']['reports'], subject: /Populate Customer Name On Card Job/) }
    it { expect { perform }.to change { customer.sources.retrieve(card_id).name }.from(nil).to('Dimon Medvedef') }
  end
end
