class ReportsMailer < ApplicationMailer
  default to: APP_CONFIG['emails']['reports']

  def job_report(report)
    @report = report
    mail subject: @report.title
  end

  def deleted_posts_too_often(user)
    @user = user
    mail subject: "[#{user.id} - #{user.email}] deleted 5 or more posts in a hour"
  end
end
