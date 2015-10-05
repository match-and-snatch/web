RSpec::Matchers.define :deliver_email do |default_scope|
  match do |block|
    matching(default_scope)

    before = ActionMailer::Base.deliveries.clone
    block.call
    after = ActionMailer::Base.deliveries.clone

    @sent_emails = after - before

    if scope.empty?
      @sent_emails.any?
    else
      matched_emails = @sent_emails.find_all do |email|
        matches = true

        scope.each do |key, value|
          email_value = email.send(key)
          matches = email_value.is_a?(value.class) || (email_value.is_a?(String) && value.is_a?(Regexp))
          matches || break

          case value
            when Array
              matches = email_value.try(:sort) == value.sort
            when Regexp
              matches = value.match(email_value)
            else
              matches = email_value == value
          end
        end

        matches
      end

      @matched_count = matched_emails.count
      @matched_one = matched_emails.count == 1
    end
  end

  chain(:matching) do |attrs|
    scope.merge!(attrs)

    case scope[:to]
      when ActiveRecord::Base
        scope[:to] = [scope[:to].email]
      when String
        scope[:to] = [scope[:to]]
      when Array
      when nil
        fail ArgumentError, 'Always test a list of recipients (missing `to:` matcher key)'
      else
        fail ArgumentError, "Expected Array of recipients, got #{scope[:to].class}"
    end
  end

  description do
    'send email'.tap do |result|
      result << " matching #{scope}" if scope.any?
    end
  end

  failure_message do
    if @matched_count > 1
      "Expected to send email once#{" to #{scope[:to]}" if scope[:to]}, but sent #{@matched_count} times"
    else
      "Expected to send email#{" to #{scope[:to]}" if scope[:to]}, but nothing was sent"
    end
  end

  def scope
    @scope ||= {}
  end

  def supports_block_expectations?
    true
  end
end