require 'sendgrid-ruby'

module Users
  class PullEmailBouncesJob
    include Concerns::Jobs::Reportable

    # Marks users with failed zip check flag if billing city does not match zip
    # (both fields specified on card update forms: subscribe / update billing info)
    # When card is removed, the flag should be reset to nil to initiate the job again
    # next time user provides billing information
    def perform
      report = new_report bounced_emails: bounces.count, unmatched_bounces: 0, bounced_users: 0

      unless Rails.env.test?
        puts '============================'
        puts '       PULL EMAIL BOUNCES'
        puts '============================'
      end

      bounces.each do |bounce|
        email = bounce['email'].downcase
        users = User.where(email: email)

        if users.exists?
          users.each do |user|
            bounce_time = Time.zone.at(bounce['created'])

            if user.email_bounced_at != bounce_time
              user.update!(email_bounced_at: bounce_time)
              report[:bounced_users] += 1
              p "Bounced user##{user.id} - #{user.email}" unless Rails.env.test?
            end
          end
        else
          report[:unmatched_bounces] += 1
          p "Unmatched bounce #{email}" unless Rails.env.test?
        end
      end

      report.forward
    rescue => e
      report.log_failure(e.message)
      report.forward
      raise
    end

    private

    # @return [Array<Hash<String>>]
    def bounces
      @bounces ||= JSON.parse(sendgrid_api.suppression.bounces.get(query_params: params).body)
    end

    # Limits to 500
    def params
      {
        'start_time' => 25.hours.ago.to_i,
        'end_time' => Time.zone.now.to_i
      }
    end

    def sendgrid_api
      @api ||= SendGrid::API.new(api_key: APP_CONFIG['sendgrid_api_key']).client
    end
  end
end
