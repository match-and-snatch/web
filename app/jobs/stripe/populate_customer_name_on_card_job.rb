module Stripe
  class PopulateCustomerNameOnCardJob
    include Concerns::Jobs::Reportable

    LIMIT = 100

    attr_reader :report

    def perform
      @report = new_report total_processed: 0,
                           processed: 0,
                           skipped: 0,
                           processed_cards: 0,
                           skipped_cards: 0,
                           failed_cards: 0

      customers = fill_customer_names
      while customers.has_more
        customers = fill_customer_names(starting_after: customers.data.last.try(:id))
      end

      report.forward
    rescue => e
      report.log_failure(e.message)
      report.forward
      raise
    end

    private

    def customers(starting_after: nil, ending_before: nil)
      Stripe::Customer.list(created: {gt: from_time, lt: to_time},
                            limit: LIMIT,
                            starting_after: starting_after,
                            ending_before: ending_before)
    end

    def fill_customer_names(starting_after: nil, ending_before: nil)
      list = customers(starting_after: starting_after, ending_before: ending_before)

      unless ::Rails.env.test?
        logger = Logger.new(STDOUT)
        logger.info "Got #{list.data.count} customers. Processing ..."
      end

      list.data.each { |customer| update_name(customer) }
      list
    end

    def update_name(customer)
      report[:total_processed] += 1
      if customer.sources.data.map(&:name).include?(nil)
        customer.sources.data.each do |source|
          if source.name
            report[:skipped_cards] += 1
          else
            begin
              card = customer.sources.retrieve(source.id)
              card.name = customer.metadata.full_name
              card.save

              report[:processed_cards] += 1
            rescue => e
              report[:failed_cards] += 1
              report.log_failure(e.message)
            end
          end
        end
        report[:processed] += 1
      else
        report[:skipped] += 1
      end
    end

    def from_time
      Time.new(2016, 9, 21).in_time_zone.beginning_of_day.to_i
    end

    def to_time
      Time.new(2016, 9, 27).in_time_zone.end_of_day.to_i
    end
  end
end
