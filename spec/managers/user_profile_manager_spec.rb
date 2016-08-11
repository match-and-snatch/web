require 'spec_helper'

describe UserProfileManager do
  let(:user) { create(:user) }
  subject(:manager) { described_class.new(user) }

  describe '#add_profile_type' do
    let(:user) { create(:user, :profile_owner) }
    let(:profile_type) { ProfileTypeManager.new.create(title: 'test') }

    specify { expect(user.profile_types).to be_empty }

    specify do
      expect { manager.add_profile_type(profile_type.title) }.to change(user.profile_types, :count).from(0).to(1)
      expect(user.profile_types).to include(profile_type)
    end

    it 'creates added_profile_type event' do
      expect { manager.add_profile_type(profile_type.title) }.to create_event(:profile_type_added)
    end

    it 'indexes profile' do
      expect { manager.add_profile_type(profile_type.title) }.to index_record(user).using_type('profiles')
    end

    context 'different title case' do
      it 'upcases first character for each word in title' do
        expect { manager.add_profile_type('band') }.to create_record(ProfileType).matching(title: 'Band')
        expect { manager.add_profile_type('rock band') }.to create_record(ProfileType).matching(title: 'Rock Band')
      end

      it 'keeps case for second characters' do
        expect { manager.add_profile_type('bAnd') }.to create_record(ProfileType).matching(title: 'BAnd')
        expect { manager.add_profile_type('roCK BAnd') }.to create_record(ProfileType).matching(title: 'RoCK BAnd')
      end

      context 'add the same type with different case' do
        before { manager.add_profile_type('band') }

        it 'does not create duplicates' do
          expect { manager.add_profile_type('bAnd') }.not_to create_record(ProfileType)
        end
      end
    end
  end

  describe '#finish_owner_registration' do
    let!(:user) { create(:user, full_name: 'Barak Obama') }
    let(:params) { {profile_name: 'The President', cost: 5} }

    subject(:finish) { manager.finish_owner_registration(params) }

    it { expect { finish }.to change { user.reload.slug }.to('thepresident') }

    context 'initially profile owner' do
      let!(:user) { create :user, full_name: 'Barak Obama', is_profile_owner: true }

      it { expect { finish }.to change { user.reload.slug }.to('thepresident') }
      it { expect { finish }.to deliver_email(to: user.email, subject: /Welcome to ConnectPal!/) }
    end

    context 'sets large cost' do
      let(:params) { {profile_name: 'The President', cost: 25} }

      it { expect { finish }.not_to deliver_email(to: user.email) }
    end

    describe '#update' do
      let(:params) { {cost: 1, profile_name: 'obama', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789'} }

      it { expect { manager.finish_owner_registration(params.merge(profile_name: 'some-random-name')) }.not_to raise_error }

      it 'updates slug' do
        expect { finish }.to change(user, :slug).to('obama')
      end

      it 'creates profile_created event' do
        expect { finish }.to create_event(:profile_created)
      end

      it 'updates cost' do
        expect { manager.finish_owner_registration(params.merge(cost: 5)) }.to change(user, :cost).to(500)
      end

      it do
        expect { manager.finish_owner_registration(params.merge(cost:' 6')) }.to change(user, :cost).to(600)
      end

      context 'registration already finished' do
        before { manager.finish_owner_registration(params) }

        it 'does not create profile_created event again' do
          expect { finish }.not_to create_event(:profile_created)
        end

        context 'passed huge cost' do
          it 'creates change cost request' do
            expect { manager.finish_owner_registration(params.merge(cost: 55)) }.to change { user.cost_change_requests.count }.from(0).to(1)
          end
          it { expect { manager.finish_owner_registration(params.merge(cost: 55)) }.to change { user.reload.cost_approved? }.from(true).to(false) }
        end

        context 'passed low cost after huge' do
          let(:params) { {cost: 55, profile_name: 'obama', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789'} }

          it 'rejects change cost request' do
            expect { manager.finish_owner_registration(params.merge(cost: 5)) }.to change { user.cost_change_requests.first.reload.rejected? }.from(false).to(true)
          end
          it { expect { manager.finish_owner_registration(params.merge(cost: 5)) }.to change { user.reload.cost_approved? }.from(false).to(true) }
        end

        context 'subscription is present' do
          let!(:subscriber) { create(:user) }

          before { SubscriptionManager.new(subscriber: subscriber).subscribe_to(user) }

          it { expect { finish }.to raise_error(ManagerError, /You have active subscribers/) }
        end
      end

      context 'empty cost' do
        let(:params) { {cost: '', profile_name: ''} }

        it { expect { finish }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:empty)) } }
        it { expect { finish rescue nil }.not_to create_event(:profile_created) }

        it { expect { manager.finish_owner_registration(params.merge(cost: 0)) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:zero)) } }
        it { expect { manager.finish_owner_registration(params.merge(cost: '-100')) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:not_a_cost)) } }
        it { expect { manager.finish_owner_registration(params.merge(cost: -200)) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:not_a_cost)) } }
        it { expect { manager.finish_owner_registration(cost: 20.00, profile_name: 'putin') }.not_to raise_error }
        it { expect { manager.finish_owner_registration(params.merge(cost: 20.01)) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:not_a_whole_number)) } }
      end

      context 'cost more or equal $30' do
        let(:params) { {cost: 45, profile_name: 'merkel'} }

        it { expect { finish }.not_to raise_error }

        it 'creates cost change request' do
          expect { manager.finish_owner_registration(params.merge(cost: 30, holder_name: 'merkel', routing_number: '123456789', account_number: '000123456789')) }.to create_record(CostChangeRequest)
        end

        it 'notify support if new change cost request was created' do
          expect(ProfilesMailer).to receive(:cost_change_request).with(user, nil, 34_50).and_return(double('mailer').as_null_object)
          manager.finish_owner_registration(params.merge(cost: 30))
        end
      end

      context 'empty slug' do
        let(:params) { {cost: 1, profile_name: ''} }

        it { expect { finish }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(profile_name: t_error(:empty)) } }
        it { expect { finish rescue nil }.not_to create_event(:profile_created) }
      end

      context 'trailing spaces in slug' do
        let(:params) { {cost: 1, profile_name: ' obama ', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789'} }

        it { expect { finish }.not_to raise_error }
      end

      context 'upcase in slug' do
        let(:params) { {cost: 1, profile_name: 'FUck', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789'} }

        it { expect { finish }.not_to raise_error }
      end

      context 'underscore in slug' do
        let(:params) { {cost: 1, profile_name: 'obama_the_president', holder_name: 'obama', routing_number: '123456789', account_number: '000123456789'} }

        it { expect { finish }.not_to raise_error }
      end

      context 'numbers in slug' do
        let(:params) { {cost: 1, holder_name: 'obama', routing_number: '123456789', account_number: '000123456789'} }

        it { expect { manager.finish_owner_registration(params.merge(profile_name: 'agent-007')) }.not_to raise_error }
        it { expect { manager.finish_owner_registration(params.merge(profile_name: '007-agent')) }.not_to raise_error }
        it { expect { manager.finish_owner_registration(params.merge(profile_name: 'a-007-gent')) }.not_to raise_error }
      end

      describe 'payment information' do
        let(:params) { {cost: 1, profile_name: 'obama', holder_name: 'holder', routing_number: '123456789', account_number: '000123456789'} }

        it { expect { finish }.to change(user, :holder_name).to('holder') }
        it { expect { finish }.to change(user, :routing_number).to('123456789') }
        it { expect { finish }.to change(user, :account_number).to('000123456789') }

        context 'empty holder name' do
          let(:params) { {cost: 1, profile_name: 'obama', holder_name: '', routing_number: '123456789', account_number: '000123456789'} }

          it { expect { finish }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to have_key(:holder_name) } }
        end

        context 'entire empty payment information' do
          let(:params) { {cost: 1, profile_name: 'obama', holder_name: '', routing_number: '', account_number: ''} }

          it { expect { finish }.not_to raise_error }
        end

        context 'invalid routing number' do
          specify do
            expect { manager.finish_owner_registration(routing_number: 'whatever') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(routing_number: t_error(:not_an_integer)) }
          end
          specify do
            expect { manager.finish_owner_registration(routing_number: '12345678') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(routing_number: t_error(:not_a_routing_number)) }
          end
          specify do
            expect { manager.finish_owner_registration(routing_number: 'wutever') rescue nil }.not_to create_event(:profile_created)
          end
        end

        context 'invalid account number' do
          specify do
            expect { manager.finish_owner_registration(account_number: 'whatever') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(account_number: t_error(:not_an_integer)) }
          end
          specify do
            expect { manager.finish_owner_registration(account_number: '12') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(account_number: t_error(:not_an_account_number)) }
          end
          specify do
            expect { manager.finish_owner_registration(routing_number: 'wutever') rescue nil }.not_to create_event(:profile_created)
          end
        end
      end
    end
  end

  describe '#toggle_accepting_large_contributions' do
    specify do
      expect { manager.toggle_accepting_large_contributions }.to change { user.reload.accepts_large_contributions? }
    end
  end

  describe '#toggle' do
    context 'visible' do
      let(:user) { create(:user, :profile_owner) }

      it { expect { manager.toggle }.to change { user.hidden? }.from(false).to(true) }

      context 'indexed profile' do
        before { update_index user }

        it { expect { manager.toggle }.to delete_record_index_document(user).from_type('profiles') }
      end
    end

    context 'hidden' do
      let(:user) { create(:user, :profile_owner, hidden: true) }

      it { expect { manager.toggle }.to change { user.hidden? }.from(true).to(false) }

      it 'indexes user' do
        expect { manager.toggle }.to index_record(user).using_type('profiles')
      end
    end
  end

  describe '#toggle_mature_content' do
    context 'has mature content' do
      let(:user) { create(:user, :profile_owner, has_mature_content: true) }

      it { expect { manager.toggle_mature_content }.to change { user.has_mature_content? }.from(true).to(false) }

      it 'indexes user' do
        expect { manager.toggle_mature_content }.to index_record(user).using_type('profiles')
      end
    end

    context 'does not have mature content' do
      let(:user) { create(:user, :profile_owner, has_mature_content: false) }

      it { expect { manager.toggle_mature_content }.to change { user.has_mature_content? }.from(false).to(true) }

      context 'indexed profile' do
        before { update_index user }

        it { expect { manager.toggle_mature_content }.to delete_record_index_document(user).from_type('profiles') }
      end
    end
  end

  describe '#enable_vacation_mode' do
    let(:reason) { 'because i can' }
    let(:user) { create :user, :profile_owner }

    subject(:enable_vacation_mode) { manager.enable_vacation_mode(reason: reason) }

    it 'enables vacation mode' do
      expect { enable_vacation_mode }.to change { user.reload.vacation_enabled? }.from(false).to(true)
    end

    it 'saves vacation start date' do
      Timecop.freeze(Time.zone.now) do
        expect { enable_vacation_mode }.to change { user.reload.vacation_enabled_at.try(:round) }.from(nil).to(Time.zone.now.round)
      end
    end

    it 'creates vacation_mode_enabled event' do
      expect { enable_vacation_mode }.to create_event(:vacation_mode_enabled)
    end

    context 'with subscribers' do
      let!(:subscriber) { create(:user, email: 'subscriber@gmail.com') }

      let!(:subscription) do
        SubscriptionManager.new(subscriber: subscriber).subscribe_to(user)
      end

      it 'sends notifications' do
        expect { enable_vacation_mode }.not_to raise_error
      end

      specify do
        stub_const('ProfilesMailer', double('mailer', vacation_enabled: double('mail', deliver: true)).as_null_object)
        expect(ProfilesMailer).to receive(:vacation_enabled).with(subscription).and_return(double('mailer').as_null_object)
        enable_vacation_mode
      end

      it { expect { enable_vacation_mode }.not_to deliver_email(to: APP_CONFIG['emails']['operations'], subject: /went on away mode/) }

      context 'with 15 or more subscribers' do
        let(:subscribers_count) { 15 }

        before { user.update_attribute(:subscribers_count, subscribers_count) }

        it { expect { enable_vacation_mode }.to deliver_email(to: APP_CONFIG['emails']['operations'], subject: /went on away mode/) }

        context 'more than 15 subscribers' do
          let(:subscribers_count) { 16 }

          it { expect { enable_vacation_mode }.to deliver_email(to: APP_CONFIG['emails']['operations'], subject: /went on away mode/) }
        end
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

  describe '#disable_message_notifications' do
    let(:user) { create :user, :profile_owner }

    context 'notifications enabled' do
      specify do
        expect { manager.disable_message_notifications }.to change { user.reload.message_notifications_enabled? }.to(false)
      end
    end

    context 'notifications disabled' do
      before do
        manager.disable_message_notifications
      end

      specify do
        expect { manager.disable_message_notifications }.to raise_error(ManagerError)
      end
    end
  end

  describe '#enable_message_notifications' do
    let(:user) { create :user, :profile_owner }

    context 'notifications disabled' do
      before do
        manager.disable_message_notifications
      end

      specify do
        expect { manager.enable_message_notifications }.to change { user.reload.message_notifications_enabled? }.to(true)
      end
    end

    context 'notifications enabled' do
      specify do
        expect { manager.enable_message_notifications }.to raise_error(ManagerError)
      end
    end
  end

  describe '#disable_vacation_mode' do
    let(:user) { create :user, :profile_owner }
    let(:vacation_start_date) { Time.zone.now }

    before do
      Timecop.freeze(vacation_start_date) do
        manager.enable_vacation_mode(reason: 'Yexa/| B DepeBH|-O')
      end
    end

    subject(:disable_vacation_mode) { manager.disable_vacation_mode }

    it 'disables vacation mode' do
      expect { disable_vacation_mode }.to change { user.reload.vacation_enabled? }.from(true).to(false)
    end

    it 'restores vacation start date' do
      expect { disable_vacation_mode }.to change { user.reload.vacation_enabled_at }.to(nil)
    end

    context 'user has suspended billing' do
      context 'with subscribed users' do
        let(:subscriber) { create(:user, email: 'subscriber@gmail.com') }

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
            UserProfileManager.new(subscriber).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
            subscriber.reload
          end

          let!(:subscription) do
            SubscriptionManager.new(subscriber: subscriber).subscribe_and_pay_for(user)
          end

          it 'does nothing with charge date since subscriber just subscribed' do
            Timecop.freeze(2.days.from_now) do
              expect { disable_vacation_mode }.not_to change { subscription.reload.charged_at }
            end
          end
        end

        context 'have already been subscribed before' do
          before { StripeMock.start }
          after { StripeMock.stop }

          before do
            UserProfileManager.new(subscriber).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
            subscriber.reload
          end

          let(:charge_time) { Date.new(2000, 12, 1).to_time }
          let(:vacation_start_date) { Time.zone.parse('2001-01-06') }

          let!(:subscription) do
            Timecop.freeze(charge_time) do
              SubscriptionManager.new(subscriber: subscriber).subscribe_and_pay_for(user)
            end
          end

          it 'moves charge date to number of days spent on vacation' do
            Timecop.freeze(Date.new(2001, 02, 03)) do
              expect { disable_vacation_mode }.to change { subscription.reload.charged_at }.from(charge_time).to(charge_time + 28.days)
            end
          end

          it 'creates vacation_mode_disabled event with affected users count' do
            expect { disable_vacation_mode }.to create_event(:vacation_mode_disabled).including_data(affected_users_count: 1)
          end
        end
      end
    end

    it 'creates vacation_mode_disabled event' do
      expect { disable_vacation_mode }.to create_event(:vacation_mode_disabled)
    end

    context 'with subscribers' do
      let!(:subscriber) { create(:user, email: 'subscriber@gmail.com') }

      let!(:subscription) do
        SubscriptionManager.new(subscriber: subscriber).subscribe_to(user)
      end

      it 'sends notifications' do
        expect { disable_vacation_mode }.not_to raise_error
      end

      specify do
        stub_const('ProfilesMailer', double('mailer', vacation_disabled: double('mail', deliver: true)).as_null_object)
        expect(ProfilesMailer).to receive(:vacation_disabled).with(subscription).and_return(double('mailer').as_null_object)
        disable_vacation_mode
      end

      it { expect { disable_vacation_mode }.not_to deliver_email(to: APP_CONFIG['emails']['operations']) }

      context 'with 15 or more subscribers' do
        let(:subscribers_count) { 15 }

        before do
          event = user.events.where(action: 'vacation_mode_enabled').last
          event.data.merge!(subscribers_count: subscribers_count)
          event.save
        end

        it { expect { disable_vacation_mode }.to deliver_email(to: APP_CONFIG['emails']['operations'], subject: /subscribers has returned from away mode/) }

        context 'more than 15 subscribers' do
          let(:subscribers_count) { 16 }

          it { expect { disable_vacation_mode }.to deliver_email(to: APP_CONFIG['emails']['operations'], subject: /subscribers has returned from away mode/) }
        end
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

  describe '#reorder_profile_types' do
    let(:first_type) { ProfileTypeManager.new.create(title: 'first') }
    let(:second_type) { ProfileTypeManager.new.create(title: 'second') }

    before do
      manager.add_profile_type(first_type.title)
      manager.add_profile_type(second_type.title)
    end

    it do
      manager.reorder_profile_types([second_type.id, first_type.id])
      expect(user.profile_types.order('profile_types_users.ordering')).to eq([second_type, first_type])
    end

    context 'ordered' do
      before { manager.reorder_profile_types([second_type.id, first_type.id]) }

      it do
        expect { manager.reorder_profile_types([first_type.id, second_type.id]) }.to change { user.profile_types.order('profile_types_users.ordering').reload }.from([second_type, first_type]).to([first_type, second_type])
      end
    end
  end

  describe '#create_profile_page' do
    let(:user) { create(:user, :profile_owner) }

    before { manager.delete_profile_page! }

    it { expect { manager.create_profile_page }.to change { user.is_profile_owner }.from(false).to(true) }

    it 'indexes user' do
      expect { manager.create_profile_page }.to index_record(user.reload).using_type('profiles')
    end
  end

  describe '#delete_profile_page' do
    let(:user) { create(:user, :profile_owner) }

    it 'returns user' do
      expect(manager.delete_profile_page).to eq(user)
    end

    specify do
      expect { manager.delete_profile_page }.to change { user.reload.is_profile_owner? }.from(true).to(false)
    end

    context 'with source subscriptions' do
      let!(:subscriber) { create(:user, email: 'subscriber@gmail.com') }
      let!(:subscription) { SubscriptionManager.new(subscriber: subscriber).subscribe_to(user) }

      it 'creates delete profile page request' do
        expect { manager.delete_profile_page }.to change { user.delete_profile_page_requests.count }.from(0).to(1)
      end

      it 'notify support if new delete profile page request was changed' do
        expect(ProfilesMailer).to receive(:delete_profile_page_request).with(user).and_return(double('mailer').as_null_object)
        manager.delete_profile_page
      end

      context 'with pending delete profile page requests' do
        before { manager.delete_profile_page }

        it 'raises error' do
          expect { manager.delete_profile_page }.to raise_error(ManagerError) { |e| expect(e.messages[:message]).to eq('You currently have a pending request to delete profile page.') }
        end
      end
    end
  end

  describe '#delete_profile_page!' do
    before { manager.create_profile_page }

    it { expect { manager.delete_profile_page! }.to change { user.is_profile_owner }.from(true).to(false) }
    it { expect { manager.delete_profile_page! }.to create_event(:profile_page_removed) }

    context 'indexed profile' do
      before { update_index user }

      it { expect { manager.delete_profile_page }.to delete_record_index_document(user).from_type('profiles') }
    end

    context 'with source subscriptions' do
      let(:subscriber) { create(:user, email: 'subscriber@gmail.com') }
      let!(:subscription) { SubscriptionManager.new(subscriber: subscriber).subscribe_to(user) }

      it { expect { manager.delete_profile_page! }.to change { user.reload.subscribers_count }.by(-1) }
      it { expect { manager.delete_profile_page! }.to create_event(:subscription_canceled).with_subject(subscription) }

      context 'with removed source subscriptions' do
        before { SubscriptionManager.new(subscription: subscription).unsubscribe }

        it { expect { manager.delete_profile_page! }.not_to raise_error }
        it { expect { manager.delete_profile_page! }.not_to change { user.subscribers_count } }
        it { expect { manager.delete_profile_page! }.not_to create_event(:subscription_canceled).with_subject(subscriber) }
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

  describe '#hide_benefits' do
    it { expect(manager.hide_benefits).to eq(user) }
    it { expect { manager.hide_benefits }.to change { user.reload.benefits_visible? }.from(true).to(false) }

    context 'benefits are hidden' do
      before { manager.hide_benefits }

      it { expect { manager.hide_benefits }.to raise_error(ManagerError, /already hidden/) }
      it { expect { manager.hide_benefits rescue nil }.not_to change { user.reload.benefits_visible? }.from(false) }
    end
  end

  describe '#show_benefits' do
    let(:user) { create(:user, benefits_visible: false) }

    it { expect(manager.show_benefits).to eq(user) }
    it { expect { manager.show_benefits }.to change { user.reload.benefits_visible? }.from(false).to(true) }

    context 'benefits are visible' do
      before { manager.show_benefits }

      it { expect { manager.show_benefits }.to raise_error(ManagerError, /already visible/) }
      it { expect { manager.show_benefits rescue nil }.not_to change { user.reload.benefits_visible? }.from(true) }
    end
  end

  describe '#pull_cc_data' do
    before { StripeMock.start }
    after { StripeMock.stop }

    subject(:pull_cc_data) do
      manager.pull_cc_data(cc_data)
    end

    let(:cc_data) do
      {stripe_token: token,
       expiry_month: 9,
       expiry_year: 2019,
       address_line_1: 'set',
       zip: '12355',
       city: 'LA',
       state: 'CA'}
    end

    context 'missing stripe token' do
      let(:token) { }

      specify do
        expect { pull_cc_data }.to raise_error(MissingCcTokenError)
      end
    end

    context 'invalid stripe token' do
      let(:token) { 'invalid' }

      xit 'stripe mocks can not handle this' do
        expect { pull_cc_data }.to raise_error(ManagerError)
      end
    end

    context 'valid stripe token' do
      let(:token_cc_data) do
        { number: '4242424242424242',
          cvc: '000',
          expiry_month: '05',
          expiry_year: '18',
          zip: '123456',
          city: 'LA',
          state: 'CA',
          address_line_1: 'Test',
          address_line_2: nil }
      end

      let(:token) { StripeMock.generate_card_token(token_cc_data) }

      specify do
        expect { pull_cc_data }.not_to raise_error
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
      expect { manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA') }.to change { user.reload.billing_failed? }.to(false)
    end

    it 'creates credit_card_updated event' do
      expect { manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA') }.to create_event(:credit_card_updated)
    end

    it 'creates credit_card_update_request' do
      expect { manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA') }.to create_record(CreditCardUpdateRequest)
    end

    context 'the card is already in the system' do
      def update_cc
        manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
      end

      before { update_cc } # generate fingerprint

      context 'another user gets locked by entering the same card' do
        let!(:another_user) { create :user }

        let :update_same_cc do
          described_class.new(another_user).update_cc_data(
            number: '4242424242424242',
            cvc: '333',
            expiry_month: '12',
            expiry_year: 2018,
            address_line_1: 'test',
            zip: '12345',
            city: 'LA',
            state: 'CA')
        end

        specify do
          expect { update_same_cc }.to change { another_user.reload.locked }.to(true)
        end

        specify do
          expect { update_same_cc }.to change { another_user.reload.lock_type }.to('billing')
        end

        context 'another user is locked' do
          before { update_same_cc }

          it 'does not lock original user account' do
            expect { update_cc }.not_to change { user.reload.locked? }.from(false)
          end
        end
      end

      it { expect { update_cc }.not_to change { user.reload.billing_failed? } }
      it { expect { update_cc }.to create_event(:credit_card_updated) }
      it { expect { update_cc }.to create_record(CreditCardUpdateRequest) }
    end

    context 'user has outstanding payments' do
      let(:target_user) { create :user, :profile_owner }

      before do
        SubscriptionManager.new(subscriber: user).subscribe_to(target_user)
      end

      it 'restores billing failed flag to false' do
        expect { manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA') }.to change { user.reload.billing_failed? }.to(false)
      end

      context 'test payment failed' do
        before do
          StripeMock.prepare_card_error(:card_declined)
        end

        it 'keeps flag in the failed state' do
          expect { manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA') rescue nil }.not_to change { user.reload.billing_failed? }.from(true)
        end
      end
    end

    context 'updated 4 times' do
      subject :update_cc_data do
        manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
      end

      before do
        manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
        manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
        manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
      end

      it 'locks user account on 4th attempt' do
        expect { update_cc_data rescue nil }.to change { user.reload.locked? }.to(true)
      end

      it 'sets billing lock reason' do
        expect { update_cc_data rescue nil }.to create_event('account_locked').with_user(user).including_data(type: 'billing', reason: 'cc_update_limit')
      end

      specify do
        expect { update_cc_data }.to raise_error(ManagerError, /locked/)
      end

      context '24 hours passed' do
        it 'allows updating CC data' do
          Timecop.travel(24.hours.since) do
            expect { update_cc_data }.not_to raise_error
          end
        end
      end

      context 'user is unlocked' do
        before { UserManager.new(user).lock }
        before { UserManager.new(user).unlock }

        it 'allows updating CC data' do
          expect { update_cc_data }.not_to raise_error
        end

        context do
          before do
            manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
            manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
            manager.update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
          end

          specify do
            expect { update_cc_data }.to raise_error(ManagerError, /locked/)
          end
        end
      end
    end
  end

  describe '#delete_cc_data!' do
    before { StripeMock.start }
    after { StripeMock.stop }

    before do
      manager.update_cc_data(number: '4242424242424242',
                             cvc: '333',
                             expiry_month: '12',
                             expiry_year: 2018,
                             address_line_1: 'test',
                             zip: '12345',
                             city: 'LA', state: 'CA')
    end

    it 'removes billing info' do
      expect { manager.delete_cc_data! }.to change { user.has_cc_payment_account? }.from(true).to(false)
    end

    it 'creates credit_card_removed event' do
      expect { manager.delete_cc_data! }.to create_event(:credit_card_removed)
    end

    it 'removes billing failed flag' do
      expect { manager.delete_cc_data! }.not_to change { user.billing_failed? }.from(false)
    end

    context 'user has failed billing' do
      before { UserManager.new(user).mark_billing_failed }

      it 'removes billing failed flag' do
        expect { manager.delete_cc_data! }.to change { user.billing_failed? }.from(true).to(false)
      end
    end

    context 'user has recurring contributions' do
      let(:target_user) { create :user, :profile_owner }

      before do
        5.times do |i|
          SubscriptionManager.new(subscriber: create(:user, email: "subscriber_#{i}@test.com")).subscribe_to(target_user)
        end
        ContributionManager.new(user: user).create(amount: 1, target_user: target_user, recurring: true)
      end

      it 'cancel all contributions' do
        expect { manager.delete_cc_data! }.to change { user.contributions.recurring.count }.from(1).to(0)
      end
    end

    context 'user has subscriptions' do
      let(:target_user) { create :user, :profile_owner }
      let(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(target_user) }

      before { subscription }

      it { expect { manager.delete_cc_data! }.to raise_error(ManagerError, /You can't remove your billing information/) }
      it { expect { manager.delete_cc_data! rescue nil }.not_to change { user.has_cc_payment_account? }.from(true) }

      context 'canceled subscriptions' do
        before { SubscriptionManager.new(subscription: subscription).unsubscribe }

        it { expect { manager.delete_cc_data! }.not_to raise_error }
        it { expect { manager.delete_cc_data! }.to change { user.has_cc_payment_account? }.from(true).to(false) }
      end
    end
  end

  describe '#update_payment_information' do
    let(:info) { {holder_name: 'holder', routing_number: '123456789', account_number: '000123456789'} }

    it { expect { manager.update_payment_information(info) }.to change(user, :holder_name).to('holder') }
    it { expect { manager.update_payment_information(info) }.to change(user, :routing_number).to('123456789') }
    it { expect { manager.update_payment_information(info) }.to change(user, :account_number).to('000123456789') }


    it 'logs update time', freeze: true do
      expect { manager.update_payment_information(info) }.to change(user, :payout_updated_at).to(Time.zone.now)
    end

    it 'creates payout_information_changed event' do
      expect { manager.update_payment_information(info) }.to create_event(:payout_information_changed)
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
      expect { manager.update_cover_picture_position(10) }.to change { user.reload.cover_picture_position_perc }.from(0).to(10)
    end

    context 'position parameter not specified' do
      specify do
        expect { manager.update_cover_picture_position }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#update_profile_name' do
    it { expect { manager.update_profile_name('Slava') }.to change { user.profile_name }.from(nil).to('Slava') }
    it { expect { manager.update_profile_name('Slava') }.to create_event(:profile_name_changed).including_data(name: 'Slava') }

    it 'strips whitespaces around the name' do
      expect { manager.update_profile_name(' Slava  ') }.to change { user.profile_name }.from(nil).to('Slava')
    end

    it 'indexes profile' do
      expect { manager.update_profile_name('Slava') }.to index_record(user).using_type('profiles')
    end

    it 'raises an error if new profile_name is empty' do
      expect { manager.update_profile_name('').to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(profile_name: t_error(:empty)) } }
      expect { manager.update_profile_name(nil).to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(profile_name: t_error(:empty)) } }
    end

    it 'raises an error if new profile_name longer than 140 characters' do
      expect { manager.update_profile_name('Hubert Blaine Wolfeschlegelsteinhausenbergerdorff Hubert Blaine Wolfeschlegelsteinhausenbergerdorff Hubert Blaine Wolfeschlegelsteinhausenbergerdorff').to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(profile_name: t_error(:too_long)) } }
    end

    context 'gross sales threshold reached' do
      before { user.update_attributes(gross_sales: 1000_00) }

      it { expect { manager.update_profile_name('Slava') }.to raise_error(ManagerError, /can't change profile name/) }

      context 'admin changes profile name for owner' do
        let(:admin) { create(:user, :admin) }

        subject(:manager) { described_class.new(user, admin) }

        it { expect { manager.update_profile_name('Slava') }.to change { user.profile_name }.from(nil).to('Slava') }
      end
    end
  end

  describe '#update_cost' do
    context do
      before do
        manager.update_cost(1)
      end

      it 'raises an error if cost is 0 or less' do
        expect { manager.update_cost(0) }.to raise_error(ManagerError)
      end

      it 'raises an error if cost is more than 9999' do
        expect { manager.update_cost(10000) }.to raise_error(ManagerError)
      end

      it 'does not raise any errors if cost is equal to 9999' do
        expect { manager.update_cost(9999) }.not_to raise_error
      end

      it 'raises an error if cost is not a number' do
        expect { manager.update_cost('123a') }.to raise_error(ManagerError)
      end

      it 'returns user' do
        expect(manager.update_cost(5)).to eq(user)
      end

      it 'raises an error if cost have invalid format' do
        expect { manager.update_cost('5.03') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:not_a_whole_number)) }
      end

      it 'does not raise an error if cost format is valid' do
        expect { manager.update_cost('5.00') }.not_to raise_error
      end

      specify do
        expect { manager.update_cost(4) }.to change { user.reload.cost }.from(100).to(400)
      end

      context 'with source subscriptions' do
        let!(:subscriber) { create(:user, email: 'subscriber@gmail.com') }
        let!(:subscription) do
          SubscriptionManager.new(subscriber: subscriber).subscribe_to(user)
        end

        it 'creates change cost request' do
          expect { manager.update_cost(5) }.to change { user.cost_change_requests.count }.from(0).to(1)
        end

        it 'notify support if new change cost request was changed' do
          expect(ProfilesMailer).to receive(:cost_change_request).with(user, 199, 699).and_return(double('mailer').as_null_object)
          manager.update_cost(5)
        end

        context 'with pending change cost requests' do
          before { manager.update_cost(10) }

          it 'raises error' do
            expect { manager.update_cost(7) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:pending_request_present)) }
          end
        end
      end
    end

    context 'cost more or equal $30' do
      it 'creates change cost request' do
        expect { manager.update_cost(30) }.to create_record(CostChangeRequest).
          matching(new_cost: 30_00)
      end

      it 'notifies support' do
        expect { manager.update_cost(30) }.to deliver_email(to: APP_CONFIG['emails']['operations'], subject: 'Notice - New Cost Change Request')
      end

      context 'with pending change cost requests' do
        before { manager.update_cost(30) }

        it 'raises error' do
          expect { manager.update_cost(45) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(cost: t_error(:pending_request_present)) }
        end
      end

      context 'with a previously rejected initial request' do
        let(:user) { create(:user, cost: 85_00) }
        let!(:request) { create :cost_change_request, :rejected, old_cost: nil, new_cost: 85_00, user: user, performed: true }

        it 'creates initial request again with old_cost set to NULL' do
          expect { manager.update_cost(30) }.to create_record(CostChangeRequest).
            matching(old_cost: nil)
        end
      end

      context 'with a previously rejected initial request' do
        let!(:request) { create :cost_change_request, :rejected, old_cost: nil, new_cost: 85_00, user: user, performed: true }

        it 'creates initial request again with old_cost set to NULL' do
          expect { manager.update_cost(30) }.to create_record(CostChangeRequest).
            matching(old_cost: nil)
        end
      end

      context 'with a previously approved initial request' do
        let(:user) { create(:user, cost: 85_00) }
        let!(:request) { create :cost_change_request, :approved, old_cost: nil, new_cost: 85_00, user: user, performed: true }

        it 'creates request with correct old_cost' do
          expect { manager.update_cost(30) }.to create_record(CostChangeRequest).
            matching(old_cost: 85_00, new_cost: 30_00)
        end
      end
    end
  end

  describe '#update_cost' do
    context 'pending initial request is present' do
      before { manager.finish_owner_registration(profile_name: 'The President', cost: 25) }

      it 'does not send welcome email if cost too high' do
        expect { manager.update_cost(6) rescue nil }.not_to deliver_email(to: user.email)
      end

      it 'sends welcome email if cost less than limit' do
        expect { manager.update_cost(5) }.to deliver_email(to: user.email, subject: /Welcome to ConnectPal!/)
      end
    end
  end

  describe '#change_cost!' do
    specify do
      expect { manager.change_cost!(cost: 400) }.to change { user.reload.cost }.from(nil).to(400)
    end

    context 'with source subscriptions' do
      let!(:subscriber) { create(:user, email: 'subscriber@gmail.com') }
      let!(:subscription) do
        SubscriptionManager.new(subscriber: subscriber).subscribe_to(user)
      end

      it 'changes cost in subscription' do
        expect { manager.change_cost!(cost: 300, update_existing_subscriptions: true) }.to change { subscription.reload.cost }.from(nil).to(300)
      end

      it 'does not change cost in subscription' do
        expect { manager.update_cost(3, update_existing_subscriptions: false) }.not_to change { subscription.reload.cost }.from(nil)
      end
    end
  end

  describe '#update_welcome_media' do
    let(:welcome_audio_data) { welcome_audio_data_params }
    let(:welcome_video_data) { welcome_video_data_params }

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
    let(:welcome_audio_data) { welcome_audio_data_params }
    let(:welcome_video_data) { welcome_video_data_params }

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

  describe '#hide_welcome_media' do
    it { expect(manager.hide_welcome_media).to eq(user) }
    it { expect { manager.hide_welcome_media }.to change { user.reload.welcome_media_hidden? }.from(false).to(true) }

    context 'welcome media is hidden' do
      before { manager.hide_welcome_media }

      it { expect { manager.hide_welcome_media }.to raise_error(ManagerError, /already hidden/) }
      it { expect { manager.hide_welcome_media rescue nil }.not_to change { user.reload.welcome_media_hidden? }.from(true) }
    end
  end

  describe '#show_welcome_media' do
    let(:user) { create(:user, welcome_media_hidden: true) }

    it { expect(manager.show_welcome_media).to eq(user) }
    it { expect { manager.show_welcome_media }.to change { user.reload.welcome_media_hidden? }.from(true).to(false) }

    context 'welcome media is visible' do
      before { manager.show_welcome_media }

      it { expect { manager.show_welcome_media }.to raise_error(ManagerError, /already visible/) }
      it { expect { manager.show_welcome_media rescue nil }.not_to change { user.reload.welcome_media_hidden? }.from(false) }
    end
  end

  describe '#update_general_information' do
    let(:another_user) { create(:user, email: 'another@gmail.com', activated: false) }

    specify do
      expect { manager.update_general_information(full_name: 'new', email: 'new_email@gmail.com') }.to change { user.reload.email }.to('new_email@gmail.com')
    end

    it 'logs email updated date', freeze: true do
      expect { manager.update_general_information(full_name: 'new', email: 'new_email@gmail.com') }.to change { user.reload.email_updated_at }.from(nil).to(Time.zone.now)
    end

    specify do
      expect { manager.update_general_information(full_name: 'new', email: 'new_email@gmail.com') }.to change { user.reload.old_email }.from(nil).to(user.email)
    end

    context 'full name contains numbers' do
      specify do
        expect { manager.update_general_information(full_name: 'new1', email: 'new_email@gmail.com') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(full_name: t_error(:contains_numbers)) }
      end

      specify do
        expect { manager.update_general_information(full_name: 'new1', email: 'new_email@gmail.com') rescue nil }.not_to change { user.reload.full_name }
      end
    end

    context 'email not changed' do
      specify freeze: true do
        expect { manager.update_general_information(full_name: 'new', email: user.email) }.not_to change { user.reload.email_updated_at }.from(nil)
      end
      specify do
        expect { manager.update_general_information(full_name: 'new', email: user.email) }.not_to change { user.reload.old_email }.from(nil)
      end
    end

    it 'returns user' do
      expect(manager.update_general_information(full_name: 'new', email: 'new_email@gmail.com')).to eq(user)
    end

    it 'does not raise error if email is taken' do
      expect { manager.update_general_information(full_name: 'new', email: another_user.email) }.not_to raise_error
    end

    context 'if another user is activated' do
      before { AuthenticationManager.new.activate(another_user.registration_token) }

      it 'raises an error' do
        expect { manager.update_general_information(full_name: 'new', email: another_user.email) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:taken)) }
      end
    end

    context 'another user is admin' do
      before { UserManager.new(another_user).make_admin }

      it 'raises an error' do
        expect { manager.update_general_information(full_name: 'new', email: another_user.email) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:taken)) }
      end

      context 'admin from config' do
        it 'raises an error' do
          expect { manager.update_general_information(full_name: 'new', email: 'szinin@gmail.com') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:taken)) }
          expect { manager.update_general_information(full_name: 'new', email: 'Szinin@gmail.com') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:taken)) }
        end
      end
    end

    context 'forbidden email' do
      it 'raises an error' do
        expect { manager.update_general_information(full_name: 'new', email: "tester@#{APP_CONFIG['forbidden_email_domains'].sample}") }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:invalid)) }
      end
    end
  end

  describe '#approve_and_change_cost!' do
    let(:request) { user.cost_change_requests.last }

    context 'new user with large cost' do
      let(:user) { create(:user, :profile_owner, cost: 35_00) }
      let!(:request) { create(:cost_change_request, user: user, new_cost: 35_00) }

      specify do
        expect { manager.approve_and_change_cost!(request) }.to change { request.approved? }.from(false).to(true)
      end
      specify do
        expect { manager.approve_and_change_cost!(request) }.to change { request.performed? }.from(false).to(true)
      end
      specify do
        expect { manager.approve_and_change_cost!(request) }.not_to change { user.cost }.from(3500)
      end
    end

    context 'existing user tries to change his cost' do
      let(:user) { create(:user, :profile_owner, cost: 5_00) }
      before { manager.update_cost(45) }

      specify do
        expect { manager.approve_and_change_cost!(request) }.to change { request.approved? }.from(false).to(true)
      end
      specify do
        expect { manager.approve_and_change_cost!(request) }.to change { request.performed? }.from(false).to(true)
      end
      specify do
        expect { manager.approve_and_change_cost!(request) }.to change { user.cost }.from(500)
      end
      specify do
        expect { manager.approve_and_change_cost!(request) }.not_to deliver_email(to: user.email)
      end

      context 'with subscribers' do
        let!(:subscriber) { create(:user, email: 'subscriber@gmail.com') }

        before { SubscriptionManager.new(subscriber: subscriber).subscribe_to(user) }

        specify do
          expect { manager.approve_and_change_cost!(request) }.not_to change { request.performed? }.from(false)
        end
        specify do
          expect { manager.approve_and_change_cost!(request) }.not_to change { user.cost }.from(500)
        end
        specify do
          expect { manager.approve_and_change_cost!(request) }.not_to deliver_email(to: user.email)
        end
      end
    end
  end

  describe '#rollback_cost!' do
    let(:request) { user.cost_change_requests.last }

    context 'new user with large cost' do
      let(:user) { create(:user, :profile_owner, cost: 35_00) }

      before do
        create :cost_change_request, :pending, user: user, old_cost: nil
      end

      it { expect { manager.rollback_cost!(request, cost: nil) }.not_to change { user.reload.cost } }
      it { expect { manager.rollback_cost!(request, cost: nil) }.to change { request.reload.rejected? }.from(false).to(true) }
      it { expect { manager.rollback_cost!(request, cost: 20) }.to raise_error(ArgumentError, /newcomer/) }
    end

    context 'existing user tries to change his cost' do
      let(:user) { create(:user, :profile_owner, cost: 500, subscription_fees: 123) }

      before { manager.update_cost(45) }

      it { expect { manager.rollback_cost!(request, cost: nil) }.not_to raise_error }
      it { expect { manager.rollback_cost!(request, cost: nil) }.to change { request.rejected? }.from(false).to(true) }

      it 'does not change old cost if new is not provided' do
        expect { manager.rollback_cost!(request, cost: nil) }.not_to change { user.cost }.from(500)
        expect { manager.rollback_cost!(request, cost: nil) }.not_to change { user.subscription_fees }.from(123)
      end

      it 'sets specified new cost' do
        expect { manager.rollback_cost!(request, cost: 20) }.to change { user.cost }.from(500).to(2000)
      end

      it { expect { manager.rollback_cost!(request, cost: 20) }.not_to deliver_email(to: user.email) }
    end
  end

  describe '#update_slug' do
    let(:user) { create(:user, slug: 'test') }

    it { expect { manager.update_slug('slava') }.to change { user.slug }.from('test').to('slava') }
    it { expect { manager.update_slug('slava-popov') }.to change { user.slug }.from('test').to('slava-popov') }
    it { expect { manager.update_slug('slava') }.to create_event(:slug_changed).including_data(slug: 'slava') }

    it 'raises an error if wrong characters are present' do
      expect { manager.update_slug(' slava12').to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(slug: t_error(:not_a_slug)) } }
    end

    it 'raises an error if new slug is empty' do
      expect { manager.update_slug('').to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(slug: t_error(:empty)) } }
      expect { manager.update_slug(nil).to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(slug: t_error(:empty)) } }
    end

    context 'slug is taken' do
      let(:another_user) { create(:user, slug: 'another') }

      it { expect { manager.update_slug('another').to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(slug: t_error(:taken)) } } }
    end

    context 'gross sales threshold reached' do
      before { user.update_attributes(gross_sales: 1000_00) }

      it { expect { manager.update_slug('slava') }.to raise_error(ManagerError, /can't update your profile page url/) }

      context 'admin changes slug for owner' do
        let(:admin) { create(:user, :admin) }

        subject(:manager) { described_class.new(user, admin) }

        it { expect { manager.update_slug('slava') }.to change { user.slug }.from('test').to('slava') }
      end
    end
  end
end
