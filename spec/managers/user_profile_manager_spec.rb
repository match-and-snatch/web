require 'spec_helper'

describe UserProfileManager do
  let(:user) { create_user }
  subject(:manager) { described_class.new(user) }

  describe '#add_profile_type' do
    let(:profile_type) { ProfileTypeManager.new.create(title: 'test') }

    specify do
      expect(user.profile_types).to be_empty
    end

    specify do
      expect { manager.add_profile_type(profile_type.title) }.to change(user.profile_types, :count).from(0).to(1)
      expect(user.profile_types).to include(profile_type)
    end

    it 'creates added_profile_type event' do
      expect { manager.add_profile_type(profile_type.title) }.to create_event(:profile_type_added)
    end
  end

  describe '#enable_vacation_mode' do
    let(:reason) { 'because i can' }
    let(:user) { create_profile email: 'profiled@gmail.com' }

    subject(:enable_vacation_mode) { manager.enable_vacation_mode(reason: reason) }

    it 'enables vacation mode' do
      expect { enable_vacation_mode }.to change { user.reload.vacation_enabled? }.from(false).to(true)
    end

    it 'creates vacation_mode_enabled event' do
      expect { enable_vacation_mode }.to create_event(:vacation_mode_enabled)
    end

    context 'with subscribers' do
      let!(:subscriber) { create_user email: 'subscriber@gmail.com' }

      let!(:subscription) do
        SubscriptionManager.new(subscriber: subscriber).subscribe_to(user)
      end

      it 'sends notifications' do
        expect { enable_vacation_mode }.not_to raise_error
      end

      specify do
        stub_const('ProfilesMailer', double('mailer', vacation_enabled: double('mail', deliver: true)).as_null_object)
        expect(ProfilesMailer).to receive(:vacation_enabled).with(subscription)
        enable_vacation_mode
      end
    end

    context 'no reason specified' do
      let(:reason) { '  ' }

      specify do
        expect { enable_vacation_mode }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(vacation_message: t_error(:empty)) }
      end

      specify { expect { enable_vacation_mode rescue nil }.not_to create_event(:vacation_mode_enabled) }
    end

    context 'already on vacation' do
      before do
        manager.enable_vacation_mode(reason: reason)
      end

      specify do
        expect { enable_vacation_mode }.to raise_error(ManagerError)
      end

      specify do
        expect { enable_vacation_mode rescue nil }.not_to create_event(:vacation_mode_enabled)
      end
    end
  end

  describe '#disable_vacation_mode' do
    let(:user) { create_profile email: 'profiled@gmail.com' }

    before do
      manager.enable_vacation_mode(reason: 'Yexa/| B DepeBH|-O')
    end

    subject(:disable_vacation_mode) { manager.disable_vacation_mode }

    it 'disables vacation mode' do
      expect { disable_vacation_mode }.to change { user.reload.vacation_enabled? }.from(true).to(false)
    end

    context 'user has suspended billing' do
      before { manager.suspend_billing }

      it 'disables suspended state' do
        expect { disable_vacation_mode }.to change { user.reload.billing_suspended? }.from(true).to(false)
      end

      context 'with subscribed users' do
        let(:subscriber) { create_user email: 'subscriber@gmail.com' }

        context 'not charged subscription' do
          let!(:subscription) do
            SubscriptionManager.new(subscriber: subscriber).subscribe_to(user)
          end

          it 'does nothing with charge date since it is not set' do
            expect { disable_vacation_mode }.not_to change { subscription.reload.charged_at }.from(nil)
          end
        end

        context 'subscribed at this month' do
          before { StripeMock.start }
          after { StripeMock.stop }

          before do
            UserProfileManager.new(subscriber).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018)
            subscriber.reload
          end

          let!(:subscription) do
            SubscriptionManager.new(subscriber: subscriber).subscribe_and_pay_for(user)
          end

          it 'does nothing with charge date since subscriber just subscribed' do
            expect { disable_vacation_mode }.not_to change { subscription.reload.charged_at }
          end
        end

        context 'have already been subscribed before' do
          before { StripeMock.start }
          after { StripeMock.stop }

          before do
            UserProfileManager.new(subscriber).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018)
            subscriber.reload
          end

          let(:charge_time) { Date.new(2001, 01, 01).to_time }

          let!(:subscription) do
            Timecop.freeze(charge_time) do
              SubscriptionManager.new(subscriber: subscriber).subscribe_and_pay_for(user)
            end
          end

          it 'moves charge date to number of days from beginning of current month' do
            Timecop.freeze(Date.new(2014, 01, 22)) do
              expect { disable_vacation_mode }.to change { subscription.reload.charged_at }.from(charge_time).to(charge_time + 22.days)
            end
          end
        end

        context 'subscribed during current month' do
          before { StripeMock.start }
          after { StripeMock.stop }

          before do
            UserProfileManager.new(subscriber).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018)
            subscriber.reload
          end

          let(:charge_time) { Time.zone.parse('2001-01-05') }

          let!(:subscription) do
            Timecop.freeze(charge_time) do
              SubscriptionManager.new(subscriber: subscriber).subscribe_and_pay_for(user)
            end
          end

          it 'moves charge date to number of days owner spent in vacation mode during subscription' do
            Timecop.freeze(Date.new(2001, 01, 07)) do
              expect { disable_vacation_mode }.to change { subscription.reload.charged_at }.from(charge_time).to(charge_time + 2.days)
            end
          end
        end
      end
    end

    it 'creates vacation_mode_disabled event' do
      expect { disable_vacation_mode }.to create_event(:vacation_mode_disabled)
    end

    context 'with subscribers' do
      let!(:subscriber) { create_user email: 'subscriber@gmail.com' }

      let!(:subscription) do
        SubscriptionManager.new(subscriber: subscriber).subscribe_to(user)
      end

      it 'sends notifications' do
        expect { disable_vacation_mode }.not_to raise_error
      end

      specify do
        stub_const('ProfilesMailer', double('mailer', vacation_disabled: double('mail', deliver: true)).as_null_object)
        expect(ProfilesMailer).to receive(:vacation_disabled).with(subscription)
        disable_vacation_mode
      end
    end

    context 'already disabled vacation' do
      before do
        manager.disable_vacation_mode
      end

      specify do
        expect { disable_vacation_mode }.to raise_error(ManagerError)
      end

      specify { expect { disable_vacation_mode rescue nil }.not_to create_event(:vacation_mode_disabled) }
    end
  end

  describe '#remove_profile_type' do
    let(:profile_type) { ProfileTypeManager.new.create(title: 'test') }

    before { manager.add_profile_type(profile_type.title) }

    specify do
      expect { manager.remove_profile_type(profile_type) }.to change(user.profile_types, :count).from(1).to(0)
      expect(user.profile_types).not_to include(profile_type)
    end

    it 'creates vacation_mode_enabled event' do
      expect { manager.remove_profile_type(profile_type) }.to create_event(:profile_type_removed)
    end
  end

  describe '#update' do
    specify do
      expect { manager.update(cost: 1, profile_name: 'some-random-name', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.not_to raise_error
    end

    it 'updates slug' do
      expect { manager.update(cost: 1, profile_name: 'obama', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.to change(user, :slug).to('obama')
    end

    it 'creates profile_created event' do
      expect { manager.update(cost: 1, profile_name: 'obama', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.to create_event(:profile_created)
    end

    it 'updates cost' do
      expect { manager.update(cost: 5, profile_name: 'obama', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.to change(user, :cost).to(500)
      expect { manager.update(cost:' 6', profile_name: 'obama', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.to change(user, :cost).to(600)
    end

    context 'empty cost' do
      specify do
        expect { manager.update(cost: '', profile_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:empty)) }
      end

      specify do
        expect { manager.update(cost: '', profile_name: '') rescue nil }.not_to create_event(:profile_created)
      end

      specify do
        expect { manager.update(cost: 0, profile_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:zero)) }
        # expect { manager.update(cost: 0, profile_name: '')}.not_to create_event(:profile_created)
      end

      specify do
        expect { manager.update(cost: '-100', profile_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:not_an_integer)) }
        # expect { manager.update(cost: '-100', profile_name: '') }.not_to create_event(:profile_created)
      end

      specify do
        expect { manager.update(cost: -200, profile_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:not_an_integer)) }
        # expect { manager.update(cost: -200, profile_name: '') }.not_to create_event(:profile_created)
      end
    end

    context 'empty slug' do
      specify do
        expect { manager.update(cost: 1, profile_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(profile_name: t_error(:empty)) }
      end

      specify do
        expect { manager.update(cost: 1, profile_name: '') rescue nil }.not_to create_event(:profile_created)
      end
    end

    context 'trailing spaces in slug' do
      specify do
        expect { manager.update(cost: 1, profile_name: ' obama ', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.not_to raise_error
      end
    end

    context 'upcase in slug' do
      specify do
        expect { manager.update(cost: 1, profile_name: 'FUck', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.not_to raise_error
      end
    end

    context 'underscore in slug' do
      specify do
        expect { manager.update(cost: 1, profile_name: 'obama_the_president', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.not_to raise_error
      end
    end

    context 'numbers in slug' do
      specify do
        expect { manager.update(cost: 1, profile_name: 'agent-007', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.not_to raise_error
      end
      specify do
        expect { manager.update(cost: 1, profile_name: '007-agent', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.not_to raise_error
      end
      specify do
        expect { manager.update(cost: 1, profile_name: 'a-007-gent', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789') }.not_to raise_error
      end
    end

    describe 'payment information' do
      specify do
        expect { manager.update(cost: 1, profile_name: 'obama', holder_name: 'holder', routing_number: '123456789', account_number: '000123456789') }.to change(user, :holder_name).to('holder')
      end
      specify do
        expect { manager.update(cost: 1, profile_name: 'obama', holder_name: 'holder', routing_number: '123456789', account_number: '000123456789') }.to change(user, :routing_number).to('123456789')
      end
      specify do
        expect { manager.update(cost: 1, profile_name: 'obama', holder_name: 'holder', routing_number: '123456789', account_number: '000123456789') }.to change(user, :account_number).to('000123456789')
      end

      context 'empty holder name' do
        specify do
          expect { manager.update(cost: 1, profile_name: 'obama', holder_name: '', routing_number: '123456789', account_number: '000123456789') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to have_key(:holder_name) }
        end
      end

      context 'entire empty payment information' do
        specify do
          expect { manager.update(cost: 1, profile_name: 'obama', holder_name: '', routing_number: '', account_number: '') }.not_to raise_error
        end
      end

      context 'invalid routing number' do
        specify do
          expect { manager.update(routing_number: 'whatever') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(routing_number: t_error(:not_an_integer)) }
        end

        specify do
          expect { manager.update(routing_number: '12345678') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(routing_number: t_error(:not_a_routing_number)) }
        end

        specify do
          expect { manager.update(routing_number: 'wutever') rescue nil }.not_to create_event(:profile_created)
        end
      end

      context 'invalid account number' do
        specify do
          expect { manager.update(account_number: 'whatever') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(account_number: t_error(:not_an_integer)) }
        end

        specify do
          expect { manager.update(account_number: '12') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(account_number: t_error(:not_an_account_number)) }
        end

        specify do
          expect { manager.update(routing_number: 'wutever') rescue nil }.not_to create_event(:profile_created)
        end
      end
    end
  end

  describe '#update_benefits' do
    let(:benefits_params) { { "0"=>"benefit", "1"=>"other benefit", "2"=>"", "3"=>"", "4"=>"", "5"=>"", "6"=>"", "7"=>"", "8"=>"", "9"=>"" } }

    specify do
      expect { manager.update_benefits(nil) }.to raise_error(ManagerError)
    end

    specify do
      expect { manager.update_benefits(nil) rescue nil }.not_to create_event(:benefits_list_updated)
    end

    specify do
      expect(manager.update_benefits(benefits_params)).to eq(user)
    end

    it 'create benefits' do
      expect { manager.update_benefits(benefits_params) }.to change { user.benefits.count }.from(0).to(2)
    end

    it 'creates benefits_list_updated event' do
      expect { manager.update_benefits(benefits_params) }.to create_event(:benefits_list_updated)
    end

    context 'with benefits' do
      let(:new_benefits_params) { { "1"=>"other new benefit" } }

      before do
        manager.update_benefits(new_benefits_params)
      end

      it 'clear old and create new' do
        expect(user.reload.benefits.count).to eq(1)
        expect(user.reload.benefits.last.message).to eq(new_benefits_params.first.last)
      end
    end
  end

  describe '#update_cc_data' do
    before { StripeMock.start }
    after { StripeMock.stop }

    before do
      UserManager.new(user).mark_billing_failed
    end

    specify do
      expect { manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018) }.to change { user.reload.billing_failed? }.to(false)
    end

    it 'creates credit_card_updated event' do
      expect { manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018) }.to create_event(:credit_card_updated)
    end

    context 'user has outstanding payments' do
      let(:target_user) { create_profile email: 'profiled@gmail.com' }

      before do
        SubscriptionManager.new(subscriber: user).subscribe_to(target_user)
      end

      it 'restores billing failed flag to false' do
        expect { manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018) }.to change { user.reload.billing_failed? }.to(false)
      end

      context 'test payment failed' do
        before do
          StripeMock.prepare_card_error(:card_declined)
        end

        it 'keeps flag in the failed state' do
          expect { manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018) }.not_to change { user.reload.billing_failed? }.from(true)
        end
      end
    end
  end

  describe '#update_payment_information' do
    specify do
      expect { manager.update_payment_information(holder_name: 'holder', routing_number: '123456789', account_number: '000123456789') }.to change(user, :holder_name).to('holder')
    end
    specify do
      expect { manager.update_payment_information(holder_name: 'holder', routing_number: '123456789', account_number: '000123456789') }.to change(user, :routing_number).to('123456789')
    end
    specify do
      expect { manager.update_payment_information(holder_name: 'holder', routing_number: '123456789', account_number: '000123456789') }.to change(user, :account_number).to('000123456789')
    end

    it 'creates payout_information_changed event' do
      expect { manager.update_payment_information(holder_name: 'holder', routing_number: '123456789', account_number: '000123456789') }.to create_event(:payout_information_changed)
    end

    context 'empty holder name' do
      specify do
        expect { manager.update_payment_information(holder_name: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to have_key(:holder_name) }
      end
      specify do
        expect { manager.update_payment_information(holder_name: '') rescue nil }.not_to create_event(:payout_information_changed)
      end
    end

    context 'invalid routing number' do
      specify do
        expect { manager.update_payment_information(routing_number: 'whatever') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(routing_number: t_error(:not_an_integer)) }
      end

      specify do
        expect { manager.update_payment_information(routing_number: '12345678') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(routing_number: t_error(:not_a_routing_number)) }
      end

      specify do
        expect { manager.update_payment_information(routing_number: '12345678') rescue nil }.not_to create_event(:payout_information_changed)
      end
    end

    context 'invalid account number' do
      specify do
        expect { manager.update_payment_information(account_number: 'whatever') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(account_number: t_error(:not_an_integer)) }
      end

      specify do
        expect { manager.update_payment_information(account_number: '12') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(account_number: t_error(:not_an_account_number)) }
      end

      specify do
        expect { manager.update_payment_information(account_number: '12') rescue nil }.not_to create_event(:payout_information_changed)
      end
    end
  end

  describe '#update_contacts_info' do
    specify do
      expect { manager.update_contacts_info(twitter: 'http://twit.ru') }.to change { user.reload.contacts_info[:twitter] }.from(nil).to('http://twit.ru')
    end

    specify do
      expect { manager.update_contacts_info(twitter: 'https://twit.ru') }.to change { user.reload.contacts_info[:twitter] }.from(nil).to('https://twit.ru')
    end

    specify do
      expect { manager.update_contacts_info(twitter: 'https://www.twit.ru') }.to change { user.reload.contacts_info[:twitter] }.from(nil).to('https://www.twit.ru')
    end

    specify do
      expect { manager.update_contacts_info(twitter: 'https://www.twit.ru?id=123') }.to change { user.reload.contacts_info[:twitter] }.from(nil).to('https://www.twit.ru?id=123')
    end

    specify do
      expect { manager.update_contacts_info(twitter: 'twit.ru') }.to change { user.reload.contacts_info[:twitter] }.from(nil).to('http://twit.ru')
    end

    it 'creates contact_info_changed event' do
      expect { manager.update_contacts_info(twitter: 'twit.ru') }.to create_event(:contact_info_changed)
    end

    context 'blank contact link' do
      specify do
        expect { manager.update_contacts_info(twitter: ' ') }.not_to change { user.reload.contacts_info[:twitter] }
      end
    end
  end

  describe '#update_cover_picture_position' do
    specify do
      expect { manager.update_cover_picture_position(10) }.to change { user.reload.cover_picture_position }.from(0).to(10)
    end

    context 'position parameter not specified' do
      specify do
        expect { manager.update_cover_picture_position }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#update_cost' do
    before do
      manager.update_cost(1)
    end

    it 'raises an error if cost is 0 or less' do
      expect { manager.update_cost(0) }.to raise_error(ManagerError)
    end

    it 'raises an error if cost is more than 9999' do
      expect { manager.update_cost(10000) }.to raise_error(ManagerError)
      expect { manager.update_cost(9999) }.not_to raise_error
    end

    it 'raises an error if cost is not a number' do
      expect { manager.update_cost('123a') }.to raise_error(ManagerError)
    end

    it 'returns user' do
      expect(manager.update_cost(5)).to eq(user)
    end

    specify do
      expect { manager.update_cost(4) }.to change { user.reload.cost }.from(100).to(400)
    end

    context 'with source subscriptions' do
      let!(:subscriber) { create_user email: 'subscriber@gmail.com' }
      let!(:subscription) do
        SubscriptionManager.new(subscriber: subscriber).subscribe_to(user)
      end

      before do
        stub_const('ProfilesMailer', double('mailer', changed_cost: double('mail', deliver: true)).as_null_object)
      end

      it 'raises error if cost changes at the same day' do
        expect { manager.update_cost(7) }.to raise_error(ManagerError)
      end

      it 'notify support if difference between new and old costs more than 3' do
        Timecop.freeze(2.days.from_now) do
          expect(ProfilesMailer).to receive(:changed_cost).with(user, 179, 599)
          manager.update_cost(5)
        end
      end

      it 'changes cost in subscription' do
        Timecop.freeze(2.days.from_now) do
          expect { manager.update_cost(3, update_existing_subscriptions: true) }.to change { subscription.reload.cost }.from(100).to(300)
        end
      end

      it 'does not change cost in subscription' do
        Timecop.freeze(2.days.from_now) do
          expect { manager.update_cost(3, update_existing_subscriptions: false) }.not_to change { subscription.reload.cost }.from(100)
        end
      end
    end
  end

  describe '#update_welcome_media' do
    let(:welcome_audio_data) { JSON.parse(welcome_audio_data_params['transloadit']) }
    let(:welcome_video_data) { JSON.parse(welcome_video_data_params['transloadit']) }

    context 'with video file' do
      specify do
        expect(manager.update_welcome_media(welcome_video_data)).to eq(user)
      end

      specify do
        expect { manager.update_welcome_media(welcome_video_data) }.to change { user.reload.welcome_video }.from(nil)
      end

      it 'creates welcome_media_added event' do
        expect { manager.update_welcome_media(welcome_video_data) }.to create_event(:welcome_media_added)
      end
      specify do
        expect { manager.update_welcome_media(welcome_video_data) }.to create_event(:video_uploaded)
      end

      context 'welcome video exist' do
        let!(:existing_video_id) { UploadManager.new(user).create_video(welcome_video_data).id }

        before do
          manager.update_welcome_media(welcome_video_data)
        end

        it 'removes existing welcome media' do
          expect(Video.users.where(uploadable_id: user.id).where(id: existing_video_id).any?).to be_falsey
          expect(user.reload.welcome_audio).to be_nil
        end

        specify do
          expect(user.reload.welcome_video).to be
        end

        specify do
          expect { manager.update_welcome_media(welcome_video_data) }.to create_event(:video_removed)
        end
      end

      context 'welcome audio exist' do
        let!(:existing_audio_id) { UploadManager.new(user).create_audio(welcome_audio_data).first.id }

        before do
          manager.update_welcome_media(welcome_video_data)
        end

        it 'removes existing welcome audio' do
          expect(Audio.users.where(uploadable_id: user.id).where(id: existing_audio_id).any?).to be_falsey
        end

        specify do
          expect(user.reload.welcome_video).to be
        end

        specify do
          expect { manager.update_welcome_media(welcome_video_data) }.to create_event(:video_removed)
        end
      end
    end

    context 'with audio file' do
      specify do
        expect(manager.update_welcome_media(welcome_audio_data)).to eq(user)
      end

      specify do
        expect { manager.update_welcome_media(welcome_audio_data) }.to change { user.reload.welcome_audio }.from(nil)
      end

      it 'creates welcome_media_added event' do
        expect { manager.update_welcome_media(welcome_audio_data) }.to create_event(:welcome_media_added)
      end
      specify do
        expect { manager.update_welcome_media(welcome_audio_data) }.to create_event(:audio_uploaded)
      end

      context 'welcome video exist' do
        let!(:existing_video_id) { UploadManager.new(user).create_video(welcome_video_data).id }

        before do
          manager.update_welcome_media(welcome_audio_data)
        end

        it 'removes existing welcome video' do
          expect(Video.users.where(uploadable_id: user.id).where(id: existing_video_id).any?).to be_falsey
        end

        specify do
          expect(user.reload.welcome_audio).to be
        end

        specify do
          expect { manager.update_welcome_media(welcome_audio_data) }.to create_event(:audio_removed)
        end
      end

      context 'welcome audio exist' do
        let!(:existing_audio_id) { UploadManager.new(user).create_audio(welcome_audio_data).first.id }

        before do
          manager.update_welcome_media(welcome_audio_data)
        end

        it 'removes existing welcome media' do
          expect(Audio.users.where(uploadable_id: user.id).where(id: existing_audio_id).any?).to be_falsey
          expect(user.reload.welcome_video).to be_nil
        end

        specify do
          expect(user.reload.welcome_audio).to be
        end

        specify do
          expect { manager.update_welcome_media(welcome_audio_data) }.to create_event(:audio_removed)
        end
      end
    end
  end

  describe '#remove_welcome_media!' do
    let(:welcome_audio_data) { JSON.parse(welcome_audio_data_params['transloadit']) }
    let(:welcome_video_data) { JSON.parse(welcome_video_data_params['transloadit']) }

    specify do
      expect(manager.remove_welcome_media!).to eq(user)
    end

    it 'creates welcome_media_removed event' do
      expect { manager.remove_welcome_media! }.to create_event(:welcome_media_removed)
    end

    context 'welcome video exist' do
      before do
        manager.update_welcome_media(welcome_video_data)
      end

      it 'removes all welcome video' do
        expect { manager.remove_welcome_media! }.to change { Video.users.where(uploadable_id: user.id).count }.from(1).to(0)
        expect(user.welcome_audio).to be_nil
      end
    end

    context 'welcome audio exist' do
      before do
        manager.update_welcome_media(welcome_audio_data)
      end

      it 'removes all welcome audio' do
        expect { manager.remove_welcome_media! }.to change { Audio.users.where(uploadable_id: user.id).count }.from(1).to(0)
        expect(user.welcome_video).to be_nil
      end
    end
  end

  describe '#suspend_billing' do
    specify do
      expect { manager.suspend_billing }.to change { user.reload.billing_suspended? }.from(false).to(true)
    end

    context 'already suspended' do
      before { manager.suspend_billing }

      specify do
        expect { manager.suspend_billing }.to raise_error(ManagerError)
      end

      specify do
        expect { manager.suspend_billing rescue nil }.not_to change { user.reload.billing_suspended? }
      end
    end
  end

  describe '#restore_billing' do
    before { manager.suspend_billing }

    specify do
      expect { manager.restore_billing }.to change { user.reload.billing_suspended? }.from(true).to(false)
    end

    context 'already restored' do
      before { manager.restore_billing }

      specify do
        expect { manager.restore_billing }.to raise_error(ManagerError)
      end

      specify do
        expect { manager.restore_billing rescue nil }.not_to change { user.reload.billing_suspended? }
      end
    end
  end
end
