module Billing
  class ValidateZipJob
    include Concerns::Jobs::Reportable

    # Marks users with failed zip check flag if billing city does not match zip
    # (both fields specified on card update forms: subscribe / update billing info)
    # When card is removed, the flag should be reset to nil to initiate the job again
    # next time user provides billing information
    def perform
      report = new_report users_to_check: users.count,
                          failed_zip_checks: 0,
                          successful_zip_checks: 0,
                          exceptions: 0

      unless Rails.env.test?
        puts '============================'
        puts '       ZIP CHECKS'
        puts '============================'
      end

      users.find_each do |user|
        message = "Validating user##{user.id} from #{user.billing_address_city} (#{user.billing_address_state}) with ZIP #{user.billing_address_zip}"

        begin
          check_zip_code!(user)
        rescue => e
          puts "Failed job user##{user.id}: #{e.message}"
          report.log_failure(e.message)
          report[:exceptions] += 1
        end

        if user.billing_zip_check_failed?
          message << " - FAILED"
          report[:failed_zip_checks] += 1
        else
          message << " - SUCCESS"
          report[:successful_zip_checks] += 1
        end

        puts message unless Rails.env.test?
      end

      report.forward
    rescue => e
      report.log_failure(e.message)
      report.forward
      raise
    end

    private

    def users
      User.where(billing_zip_check_failed: nil).where.not(stripe_card_id: nil)
    end

    # @param user [User]
    def check_zip_code!(user)
      geocode = Geokit::Geocoders::MultiGeocoder.geocode(user.billing_address_zip)
      return unless geocode

      city = geocode.try(:city)
      user.billing_zip_check_failed = city.blank? || (city.downcase != user.billing_address_city.try(:downcase))
      user.save!
    end
  end
end

