class ContributionsMailer < ApplicationMailer
  add_template_helper ApplicationHelper

  def sent(contribution)
    @contribution = contribution
    mail to: @contribution.user.email, subject: "You have successfully made a contribution to #{contribution.target_user.name}!"
  end

  def received(contribution)
    @contribution = contribution
    mail to: @contribution.target_user.email, subject: "You have received a contribution from #{contribution.user.name}!"
  end
end
