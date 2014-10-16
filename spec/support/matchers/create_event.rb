RSpec::Matchers.define :create_event do |action|
  match do |block|
    raise ArgumentError, 'Must specify an action' if action.blank?

    if @data
      initial_event_ids = fetch_events(action).pluck(:id)
      block.call
      event_ids = fetch_events(action).pluck(:id)
      diff_ids = (event_ids - initial_event_ids)

      if diff_ids.count != 1
        failures << (diff_ids.count.zero? ? "No events created." : "Created more than one event.")
        false
      else
        result = true
        event = Event.find(diff_ids.first)

        @data.each do |key, value|
          if event.data[key] != value
            failures << "Missing data :#{key} => #{value} (actual data value is /#{event.data[key]}/)"
            result = false
          end
        end

        result
      end
    else
      initial_events_count = fetch_events(action).count
      block.call
      events_count = fetch_events(action).count
      initial_events_count + 1 == events_count
    end
  end

  chain(:with_user) do |user|
    @user = user
  end

  chain(:including_data) do |data|
    @data = data
  end

  description do
    "create an event #{action}".tap do |result|
      result << " with user ##{@user.id} (#{@user.email})" if @user
      result << " including data #@data" if @data
    end
  end

  failure_message do
    "expected to #{description}. #{failures.to_sentence}"
  end

  def failures
    @failures ||= []
  end

  def fetch_events(action)
    Event.where(action: action.to_s).tap do |scope|
      scope.merge!(where: {user_id: @user.id}) if @user
    end
  end

  def supports_block_expectations?
    true
  end
end
