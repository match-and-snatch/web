module Stats
  class UpdateGrossSalesStatsJob
    def self.perform
      puts "Start #{Time.zone.now.to_s(:short)}" unless Rails.env.test?
      User.joins(:source_payments)
        .select('users.*, SUM(payments.amount) AS transfer')
        .group('users.id')
        .having('SUM(payments.amount) != users.gross_sales').find_each do |user|
        puts "Updated user #{user.id} - #{user.email}: changed from #{user.gross_sales} to #{user.transfer}" unless Rails.env.test?
        user.update_attribute(:gross_sales, user.transfer)
      end
      puts "Finish #{Time.zone.now.to_s(:short)}" unless Rails.env.test?
    end
  end
end
