class ApplicationMailer < ActionMailer::Base
  layout 'mail'
  default from: 'Connectpal <noreply@connectpal.com>'
  default content_type: 'text/html'
end