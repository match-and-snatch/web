class JobReportsMailer < ApplicationMailer
  def report(report)
    @report = report
    mail to: APP_CONFIG['emails']['reports'], subject: @report.title
  end
end
