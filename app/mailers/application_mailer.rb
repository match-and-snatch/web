class ApplicationMailer < ActionMailer::Base
  layout 'mail'
  default from: 'Connectpal <noreply@connectpal.com>'

  extend Delayable

  def self.queue
    :mail
  end

  def self.perform_without_delay(*args)
    super.deliver
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
