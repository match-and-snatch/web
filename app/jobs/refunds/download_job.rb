module Refunds
  class DownloadJob
    include Concerns::Jobs::Reportable

    LIMIT = 100

    attr_reader :report

    def perform
      @report = new_report downloaded_refunds: 0,
                           total_refunds_on_stripe: 0,
                           stored_refunds_in_db: Refund.count

      recently_performed_refund = Refund.order(refunded_at: :desc).first.try(:stripe_refund_id)

      refunds_list = get_refunds(ending_before: recently_performed_refund)

      while refunds_list.has_more
        refunds_list = if recently_performed_refund
                         get_refunds(ending_before: refunds_list.data.first.try(:id))
                       else
                         get_refunds(starting_after: refunds_list.data.last.try(:id))
                       end
      end

      report[:total_refunds_on_stripe] = refunds_list.total_count
      report[:stored_refunds_in_db] = Refund.count

      report.forward
    rescue => e
      report.log_failure(e.message)
      report.forward
      raise
    end

    private

    def get_refunds(starting_after: nil, ending_before: nil)
      list = Stripe::Refund.all(limit: LIMIT, starting_after: starting_after, ending_before: ending_before, include: [:total_count])
      list.data.each { |refund| create_refund(refund) }
      list
    end

    def create_refund(refund)
      payment = Payment.find_by_stripe_charge_id(refund.charge)
      Refund.create refund_params(refund, payment: payment)
      report[:downloaded_refunds] += 1
    end

    def refund_params(refund, payment: nil)
      {
        stripe_refund_id: refund.id,
        amount: refund.amount,
        balance_transaction: refund.balance_transaction,
        charge: refund.charge,
        currency: refund.currency,
        metadata: refund.metadata.to_hash,
        reason: refund.reason,
        receipt_number: refund.receipt_number,
        status: refund.status,
        refunded_at: Time.zone.at(refund.created)
      }.tap do |params|
        if payment
          params[:payment_id] = payment.id
          params[:user_id] = payment.user_id
          params[:payment_amount] = payment.subscription_cost
          params[:payment_date] = payment.created_at
        end
      end
    end
  end
end
