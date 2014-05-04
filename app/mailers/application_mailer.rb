class ApplicationMailer < ActionMailer::Base
  layout 'mail'
  default from: 'Connectpal <noreply@connectpal.com>'
  default content_type: 'text/html'

  def mail(*args)
    super(*args) do |format|
      format.html do
        Slim::Engine.with_options(pretty: true, tabsize: 1) do
          render layout: true
        end
      end
    end
  end
end