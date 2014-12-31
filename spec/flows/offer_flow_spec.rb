require 'spec_helper'

describe OfferFlow do
  let(:performer) { User.new }
  let(:offer) { nil }
  subject(:flow) { OfferFlow.new(performer: performer, subject: offer) }

  describe '#create' do
    let(:create) { flow.create(title: 'test') }
    it { expect { create }.to change { flow.offer }.from(nil) }
  end
end