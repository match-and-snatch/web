class ApplicationMailer < ActionMailer::Base
  layout 'mail'
  default from: 'Connectpal <noreply@connectpal.com>'

  def self.delay
    delayer
  end

  def self.delayer
    @delayer ||= Delayer.new(self)
  end

  def self.perform(method_name, *args)
    public_send(method_name, *delayer.decode_args(args)).deliver
  rescue Resque::TermException
    Resque.enqueue(self, method_name, *args)
  end

  def self.queue
    :mail
  end

  def mail(*args)
    super(*args) do |format|
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
end