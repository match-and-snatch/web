class TransferManager < BaseManager
  attr_reader :recipient

  # @param [Recipient, nil] recipient
  def initialize(recipient: nil)
    raise ArgumentError unless recipient.is_a?(User)
    @recipient = recipient
  end

  # @param [String, Float] amount in dollars
  # @param [String] descriptor
  def transfer(amount: nil, descriptor: nil)
    validate! do
      fail_with amount: :blank if amount.blank?
      fail_with descriptor: :blank if descriptor.blank?

      amount = (amount.to_f * 100).to_i
      fail_with amount: :zero if amount.zero?
    end

    transfer = Stripe::Transfer.create amount: amount,
                                       currency: 'usd',
                                       recipient: stripe_recipient_id,
                                       statement_descriptor: descriptor,
                                       description: descriptor

    log_entry = StripeTransfer.create user: @recipient,
                                      stripe_response: transfer.as_json,
                                      amount: amount,
                                      description: descriptor

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
      email: @recipient.email,
      description: @recipient.description)

    @recipient.stripe_recipient_id = _stripe_recipient['id']
    @recipient.save!
  end

  def stripe_recipient_id
    @stripe_recipient_id ||= begin
      unless @recipient.stripe_recipient_id
        authorize!
      end
      @recipient.stripe_recipient_id
    end
  end
end