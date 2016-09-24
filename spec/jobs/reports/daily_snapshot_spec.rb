describe Reports::DailySnapshot do
  subject(:perform) { described_class.new.perform }

  it { expect { perform }.to deliver_email(to: APP_CONFIG['emails']['reports'], subject: /Daily Snapshot/) }
end
