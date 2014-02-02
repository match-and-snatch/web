require 'spec_helper'

describe SubscriptionManager do
  let(:subscriber) { AuthenticationManager.new('szinin@gmail.com', 'password').register('login') }
  let(:another_user) { AuthenticationManager.new('another@user.com', 'password').register('another') }

  subject(:manager) { described_class.new(subscriber) }

  describe '#subscribe_to' do
    context 'another user' do
      subject { manager.subscribe_to(another_user) }

      it { should be_a Subscription }
      it { should be_valid }
      it { should_not be_new_record }

      specify do
        expect { manager.subscribe_to(another_user) }.to change { Subscription.count }.by(1)
      end
    end

    context 'any unsubscribable thing' do
      specify do
        expect { manager.subscribe_to(Subscription) }.to raise_error(ArgumentError, /Cannot subscribe/)
      end
    end
  end
end