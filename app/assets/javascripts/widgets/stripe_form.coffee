#= require ./form

class bud.widgets.StripeForm extends bud.widgets.Form
  @SELECTOR: '.StripeForm'

  initialize: ->
    super
    @after_callback = @request_token
    @$stripe_token_field = $('<input type="hidden" name="stripe_token" />')
    @$stripe_token_field.appendTo(@$container)
    @$stripe_error_container = @$container.find('[data-field=stripe_token]')

  request_token: =>
    @enable_pending_state()
    @$stripe_token_field.val('')
    @$stripe_error_container.hide().html('')
    @$container.find("[data-stripe=#{@stripe_error_param}]").removeClass('has-error').addClass('has-valid')
    @$container.find("[data-field=#{@error_param}]").hide().html('')
    @error_param = null
    @stripe_error_param = null

    Stripe.card.createToken(@$container, @on_token_received)

  on_token_received: (status, response) =>
    if response.error
      @$stripe_token_field.val('')

      @stripe_error_param = response.error.param
      @error_param = if @stripe_error_param == 'exp_year' || @stripe_error_param == 'exp_month'
       'expiry_date'
      else
        @stripe_error_param

      @$container.find("[data-stripe=#{@stripe_error_param}]").removeClass('has-valid').addClass('has-error')
      @$container.find("[data-field=#{@error_param}]").show().html(response.error.message)
      @disable_pending_state()
    else
      @$stripe_token_field.val(response.id)
      @submit =>
        @after_callback = @request_token
        @disable_pending_state()

  on_after: =>
    @$stripe_token_field.val('')
    super

