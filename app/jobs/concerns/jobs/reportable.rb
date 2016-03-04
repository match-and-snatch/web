module Concerns::Jobs::Reportable
  class Report < Hash
    attr_reader :name, :started_at, :forwarded_at, :errors

    def initialize(name: , **args)
      super

      @name = name
      @errors = {}
      @started_at = Time.zone.now

      self.merge!(args)
    end

    def title
      "[#{Rails.env}] Report for #{name} - #{started_at.strftime('%A, %d %B')}"
    end

    def forward
      @forwarded_at = Time.zone.now
      ReportsMailer.job_report(self).deliver_now
    end

    def execution_time
      forwarded_at - started_at
    end

    def log_failure(message)
      errors[message] ? errors[message] += 1 : errors[message] = 1
    end
  end

  private

  def new_report(**args)
    Report.new(name: self.class.name.titleize, **args)
  end
end
