class ApplicationMailer < ActionMailer::Base
  layout 'mail'
  default from: 'Connectpal <noreply@connectpal.com>'
end