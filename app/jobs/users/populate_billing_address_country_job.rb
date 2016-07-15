module Users
  class PopulateBillingAddressCountryJob
    def perform
      i = 0
      total = users.count
      users.find_in_batches do |group|
        group.each do |user|
          begin
            customer = Stripe::Customer.retrieve(user.stripe_user_id)
            data = customer.sources.data
            user.update_column(:billing_address_country, data.first.country) if data && data.any?
            i += 1
          rescue Stripe::InvalidRequestError
            puts "Can't process user with id #{user.id}" unless Rails.env.test?
          end
        end
        puts "processed #{i} from #{total}" unless Rails.env.test?
      end
    end

    private

    def users
      User.where.not(stripe_user_id: nil).where(billing_address_country: nil)
    end
  end
end
