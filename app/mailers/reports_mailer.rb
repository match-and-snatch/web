class ReportsMailer < ApplicationMailer
  default to: APP_CONFIG['emails']['reports']

  # @param report [Report]
  def job_report(report)
    @report = report
    mail subject: @report.title
  end

  # @param report [User]
  def deleted_posts_too_often(user)
    @user = user
    mail to: APP_CONFIG['emails']['deleted_posts'], subject: "[#{user.id} - #{user.email}] deleted 5 or more posts in a day"
  end

  def owner_went_on_vacation(user)
    @user = user
    mail to: APP_CONFIG['emails']['operations'], subject: "[#{user.id} - #{user.email}] with #{user.subscribers_count} subscribers went on away mode"
  end

  def owner_returned_from_vacation(user, event)
    @user = user
    @event = event
    mail to: APP_CONFIG['emails']['operations'], subject: "[#{user.id} - #{user.email}] with #{user.subscribers_count} subscribers has returned from away mode"
  end
end
