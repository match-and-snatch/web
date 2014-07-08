class PagesController < ApplicationController

  def about
    layout.title = 'ConnectPal.com - About'
  end

  def directory
    layout.title = 'ConnectPal.com - Profile Directory'
  end

  def pricing
    layout.title = 'ConnectPal.com - Pricing'
  end

  def contact_us
    layout.title = 'ConnectPal.com - Contact Us'
  end

  def terms_of_use
    layout.title = 'ConnectPal.com - Terms Of Use'
  end

  def privacy_policy
    layout.title = 'ConnectPal.com - Privacy Policy'
  end

  def faq
    layout.title = 'ConnectPal.com - FAQ'
  end
end