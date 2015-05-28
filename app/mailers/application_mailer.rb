class ApplicationMailer < ActionMailer::Base
  layout 'mail'
  default from: 'ConnectPal <noreply@connectpal.com>'

  def self.queue
    :mail
  end

  def self.perform(*args)
    #if Rails.env.production?
    #  ActiveRecord::Base.establish_connection(ENV['HEROKU_POSTGRESQL_PINK_URL'])
    #end
    super(*args).deliver_now
  end

  def mail(headers = {}, &block)
    unless Rails.env.production?
      headers[:to] = "\"#{headers[:to]}\" <debug@connectpal.com>"
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
