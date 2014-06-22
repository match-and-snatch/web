class RecipientManager
  attr_reader :recipient, :errors

  # @param [Recipient, nil] recipient
  def initialize(recipient = nil)
    raise ArgumentError unless recipient.is_a?(Recipient) || recipient.nil?
    @recipient = recipient || Struct.new(:id, :stripe_id, :client, :user).new(nil, 'self')
  end

  # @param [String, Float] amount in dollars
  # @param [String] descriptor
  def transfer(amount, descriptor)
    amount = (amount.to_f * 100).to_i
    return fail_with! amount: 'Must be greater than zero' if amount.zero?

    transfer = Stripe::Transfer.create amount: amount,
                                       currency: 'usd',
                                       recipient: recipient.stripe_id,
                                       statement_descriptor: descriptor,
                                       description: descriptor

    log_entry = StripeTransfer.create recipient_id: recipient.id,
                                      user: recipient.user,
                                      stripe_response: transfer.as_json,
                                      amount: amount,
                                      description: descriptor

    return fail_with! log_entry.errors if log_entry.new_record?
    true
  end

  def save(attributes)
    recipient.attributes = attributes
    return fail_with { recipient.errors } unless recipient.valid?

    if recipient.authorized?
      recipient.changed? or return true

      recipient.assync?.tap do |assync|
        recipient.save and (sync_stripe_recipient! if assync)
      end
    else
      recipient.save and authorize! or return fail_with! recipient.errors
    end

    true
  rescue Stripe::InvalidRequestError => e
    fail_with { {stripe: e.message} }
  end

  private

  def fail_with(&block)
    @errors.merge!(block.call)
    false
  end

  def sync_stripe_recipient!
    stripe_recipient = Stripe::Recipient.retrieve(recipient.stripe_id)
    stripe_recipient.name = recipient.name
    stripe_recipient.type = recipient.account_type
    stripe_recipient.bank_account = bank_account_data
    stripe_recipient.email = recipient.email
    stripe_recipient.description = recipient.description
    stripe_recipient.save
  end

  # Creates new recipient on Stripe
  def authorize!
    stripe_recipient = ::Stripe::Recipient.create(
      name: recipient.name,
      type: recipient.account_type,
      bank_account: bank_account_data,
      email: recipient.email,
      description: recipient.description)

    recipient.stripe_id = stripe_recipient['id']
    recipient.save!
  end

  def bank_account_data
    {
      country: recipient.country || 'US',
      routing_number: recipient.routing_number,
      account_number: recipient.account_number,
    }
  end
end