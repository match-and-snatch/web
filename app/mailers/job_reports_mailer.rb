class JobReportsMailer < ApplicationMailer
  def report(report)
    @report = report
    mail to: 'debug@connectpal.com', subject: @report.title
  end
end
