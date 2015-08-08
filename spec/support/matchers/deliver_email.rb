RSpec::Matchers.define :deliver_email do |default_scope|
  match do |block|
    enable_notifications! do
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
            matches = email_value.kind_of?(value.class) ||
              (email_value.is_a?(String) && value.is_a?(Regexp)) or break

            case value
            when Array
              matches = email_value.try(:sort) == value.sort or break
            when Regexp
              matches = !!value.match(email_value) or break
            else
              matches = email_value == value or break
            end
          end

          matches
        end

        @matched_multiple = matched_emails.count > 1
        @matched_one = matched_emails.count == 1
      end
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
    else
      raise ArgumentError, "Expected Array of recipients, got #{scope[:to].class}"
    end
  end

  description do
    'send email'.tap do |result|
      result << " matching #{scope}" if scope.any?
    end
  end

  failure_message do
    if @matched_multiple
      "Expected to send email once#{" to #{scope[:to]}" if scope[:to]}, but sent #@matched_multiple times"
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
