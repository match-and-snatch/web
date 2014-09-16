class TransferManager < BaseManager
  attr_reader :recipient

  # @param [User] recipient
  def initialize(recipient: nil)
    raise ArgumentError unless recipient.is_a?(User)
    @recipient = recipient
  end

  # @param [String, Float] amount in dollars
  # @param [String] descriptor
  def transfer(amount: nil, descriptor: nil, month: nil)
    validate! do
      fail_with amount: :blank if amount.blank?
      fail_with descriptor: :blank if descriptor.blank?
      fail_with descriptor: :too_long if descriptor.length > 100

      amount = (amount.to_f * 100).to_i
      fail_with amount: :zero if amount.zero?
    end

    stripe_transfer = Stripe::Transfer.create amount: amount,
                                        currency: 'usd',
                                        recipient: stripe_recipient_id,
                                        statement_descriptor: descriptor,
                                        description: descriptor

    EventsManager.transfer_sent(recipient: @recipient)
    month = month.present? ? month.to_i : Time.zone.now.month
    current_time = Time.zone.now
    created_at = current_time - (current_time.month - month).months
    log_entry = StripeTransfer.create user: @recipient,
                                      stripe_response: stripe_transfer.as_json,
                                      amount: amount,
                                      description: descriptor,
                                      created_at: created_at

    fail_with! log_entry.errors if log_entry.new_record?
    true
  end

  private

  # Creates new recipient on Stripe
  def authorize!
    _stripe_recipient = ::Stripe::Recipient.create(
      name: @recipient.holder_name,
      type: 'individual',
      bank_account: @recipient.bank_account_data,
      email: @recipient.email)

    @recipient.stripe_recipient_id = _stripe_recipient['id']
    @recipient.save!
  end

  def stripe_recipient_id
    @stripe_recipient_id ||= begin
      authorize! unless @recipient.stripe_recipient_id
      @recipient.stripe_recipient_id
    end
  end
end
