namespace :stripe do
  desc 'Sets customer name where it is empty'
  task populate_customer_name: :environment do
    Stripe::PopulateCustomerNameOnCardJob.new.perform
  end
end
