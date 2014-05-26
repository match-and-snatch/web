class AddChargedAtToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :charged_at, :datetime

    Subscription.reset_column_information

    Payment.where(created_at: nil).find_each do |p|
      p.created_at = p.target.try(:created_at)
      p.save!
    end

    Subscription.find_each do |s|
      if s.target.blank? || s.user.blank?
        puts "destroying #{s.id}"
        s.destroy
      elsif s.payments.any?
        s.charged_at = s.payments.order('created_at').last.try(:created_at) || s.created_at
        s.save!
      end
    end
  end
end
