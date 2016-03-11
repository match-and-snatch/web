class ApplicationMailer < ActionMailer::Base
  include ActionView::Helpers::UrlHelper

  add_template_helper ApplicationHelper
  add_template_helper UserLinksHelper

  layout 'mail'
  default from: 'ConnectPal <noreply@connectpal.com>'

  def self.queue
    :mail
  end

  def self.perform(*args)
    super(*args).deliver_now
  end

  def mail(headers = {}, &block)
    unless Rails.env.production? || Rails.env.test?
      headers[:to] = "\"#{headers[:to]}\" <#{APP_CONFIG['emails']['debug']}>"
    end

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
end
