class ApplicationMailer < ActionMailer::Base
  include CensorshipHelper

  add_template_helper CensorshipHelper

  layout 'mail'
  default from: 'ConnectPal <noreply@connectpal.com>'

  attr_reader :recipient, :payload

  def self.queue
    :mail
  end

  def self.perform(*args)
    super(*args).deliver_now
  end

  def self.subscribe(event_name, &block)
    MailerProxy.new(self).subscribe(event_name, &block)
  end

  def mail(headers = {}, &block)
    unless Rails.env.production? || Rails.env.test?
      headers[:to] = "\"#{headers[:to]}\" <debug@connectpal.com>"
    end

    headers[:subject] = cut_adult_words(headers[:subject])

    super(headers) do |format|
      block.call if block

      format.text(content_transfer_encoding: 'base64') do
        render(layout: true, formats: [:html])
        render text: Base64.encode64(self.response_body)
      end

      format.html(content_transfer_encoding: 'base64') do
        render(layout: true, formats: [:html])
        render text: Base64.encode64(self.response_body)
      end
    end
  end

  private

  class MailerProxy

    # @param mailer_class [ApplicationMailer]
    def initialize(mailer_class)
      @mailer = mailer_class
    end

    # @param event_name [String]
    def subscribe(event_name, &block)
      @event_name = event_name
      instance_eval(&block)

      Flows::Subscriber.subscribe(@event_name) do |event|
        @recipients_block or raise ArgumentError, 'No recipients'
        @event = event

        deliver = -> (recipient) {
          @mailer.public_send(@email_name, recipient, payload).deliver_now unless recipient.locked?
        }

        recipients = instance_eval(&@recipients_block)

        case recipients
        when ActiveRecord::Relation
          recipients.where(locked: false).find_each(&deliver)
        when Array
          recipients.each(&deliver)
        end
      end
    end

    private

    # @param template [String] template name
    def email(template = nil, &block)
      @email_name = template || @event_name
      subject_block = @subject

      @mailer.send(:define_method, @email_name) do |recipient, payload|
        @payload = payload
        @recipient = recipient
        @to = case @recipient
              when String, Array then @recipient
              when User then @recipient.email
              else
                raise ArgumentError, "Expected recipient, got #{@recipient.inspect}"
              end

        instance_eval(&block)

        @subject ||= case subject_block
                     when String then subject_block
                     when Proc then instance_eval(&subject_block)
                     else
                       'ConnectPal'
                     end

        mail to: @to, subject: @subject
      end
    end

    def payload
      @event.try(:payload) || {}
    end

    def recipients(&block)
      @recipients_block = block
    end

    # @param subject_str [String]
    def subject(subject_str = nil, &block)
      @subject = block || subject_str
    end
  end
end
