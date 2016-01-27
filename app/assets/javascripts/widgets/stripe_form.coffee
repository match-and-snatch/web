#= require ./form

class bud.widgets.StripeForm extends bud.widgets.Form
  @SELECTOR: '.StripeForm'

  initialize: ->
    super
    @after_callback = @requestToken
    @$stripe_token_field = $('<input type="hidden" name="stripe_token" />')
    @$stripe_token_field.appendTo(@$container)
    @$stripe_error_container = @$container.find('[data-field=stripe_token]')

  requestToken: =>
    @enable_pending_state()
    @$stripe_token_field.val('')
    @$stripe_error_container.hide().html('')

    Stripe.card.createToken(@$container, @onTokenReceived)

  onTokenReceived: (status, response) =>
    if response.error
      @$stripe_error_container.show().html(response.error.message)
      @disable_pending_state()
    else
      @$stripe_token_field.val(response.id)
      @submit =>
        @after_callback = @requestToken
        @disable_pending_state()

