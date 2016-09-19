require 'spec_helper'

RSpec.describe Users::PullEmailBouncesJob do
  let(:job) { described_class.new }
  subject(:perform) { job.perform }

  let(:bounces) { [] }

  before do
    allow(job).to receive(:bounces).and_return(bounces)
  end

  it { expect { perform }.to deliver_email(to: APP_CONFIG['emails']['reports'], subject: /Pull Email Bounces Job/) }

  context 'per user' do
    let!(:user) { create :user, email: 'not@matched.com' }

    context 'no bounces match' do
      it { expect { perform }.not_to change { user.reload.email_bounced_at }.from(nil) }
    end

    context 'bounces matched' do
      let(:time) { 1_473_640_127 }
      let(:bounces) { [{'email' => 'NOT@matched.com', 'created' => time}] }
      it { expect { perform }.to change { user.reload.email_bounced_at }.to(Time.zone.at(time)) }
      it { expect { perform }.to change { user.reload.updated_at } }

      context 'duplicate user' do
        let!(:another_user) { create :user, email: 'not@matched.com' }

        it { expect { perform }.to change { user.reload.email_bounced_at }.to(Time.zone.at(time)) }
        it { expect { perform }.to change { another_user.reload.email_bounced_at }.to(Time.zone.at(time)) }
      end

      context 'same job already performed' do
        before { job.perform }

        it { expect { perform }.not_to change { user.reload.updated_at } }
        it { expect { perform }.not_to change { user.reload.email_bounced_at } }
      end
    end
  end
end
