describe 'deliver_email' do
  def send_email
    AuthMailer.forgot_password(user).deliver_now
  end

  let(:user) { create :user }

  specify do
    expect { send_email }.to deliver_email(to: user)
  end

  specify do
    expect { send_email }.to deliver_email(to: user, subject: 'Requested password change')
  end

  specify do
    expect { send_email }.to deliver_email(to: user, subject: 'Requested password change')
  end

  specify do
    expect { send_email }.to deliver_email(to: user, subject: /requested/i)
  end

  specify do
    expect { send_email }.to deliver_email(to: user.email)
  end

  specify do
    expect { send_email }.to deliver_email(to: [user.email])
  end

  specify do
    expect { send_email }.not_to deliver_email(to: 'another@random.user')
  end

  specify do
    expect { send_email }.not_to deliver_email(to: user, subject: 'Wrong subject')
  end

  specify do
    expect do
      expect do
        send_email
        send_email
      end.to deliver_email(to: user)
    end.to raise_error(/2 times/)
  end

  specify do
    expect do
      expect do
        send_email
        send_email
        send_email
      end.to deliver_email(to: user)
    end.to raise_error(/3 times/)
  end
end
