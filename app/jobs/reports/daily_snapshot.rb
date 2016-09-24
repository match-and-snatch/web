module Reports
  class DailySnapshot
    include ActionView::Helpers::NumberHelper
    include Concerns::Jobs::Reportable

    attr_reader :report

    def perform
      @report = new_report subscribers: "#{overview.daily_subscribers_count} (by events: #{overview.daily_total_subscribers_count})",
                           unsubscribers: "#{overview.daily_unsubscribers_count} (by events: #{overview.daily_total_unsubscribers_count})",
                           failed_payments: overview.daily_failed_payments_count,
                           gross_sales: cents_to_dollars(overview.daily_gross_sales),
                           stripe_fees: cents_to_dollars(overview.daily_stripe_fees),
                           recurring_subscription_revenue: cents_to_dollars(overview.daily_recurring_subscriptions_revenue),
                           new_subscription_revenue: cents_to_dollars(overview.daily_new_subscriptions_revenue),
                           contributions: cents_to_dollars(overview.daily_contributions_revenue)

      report.forward
    rescue => e
      report.log_failure(e.message)
      report.forward
      raise
    end

    private

    def overview
      @overview ||= OverviewPresenter.new
    end

    def cents_to_dollars(cost)
      number_to_currency(cost.to_f / 100.0)
    end
  end
end
