class bud.widgets.Validator extends bud.Widget
  @SELECTOR: '[validate]'

  initialize: ->
    @$form = @$container.parents('form')
    @$message_container = @$form.find("[data-field='#{@$container.attr('name')}'], [data-field='#{@$container.data('error_field')}']")
    @error_messages = window.bud.layout.error_messages or {}
    @validators = @get_validators()

    @$container.on 'focusout', @validate
    @$container.on 'keyup', @validate

  validate: =>
    @mark_as_valid()

    _.find @validators, (validator) =>
      switch validator[0]
        when 'require' then @validate_require()
        when 'digit'   then @validate_digit()
        when 'slug'    then @validate_slug()
        when 'email'   then @validate_email()
        when 'zero'    then @validate_zero()
        when 'maximum' then @validate_maximum(validator[1])
        when 'min_length'   then @validate_min_length(validator[1])
        when 'cc_number'    then @validate_cc_number()
        when 'expiry_month' then @validate_expiry_month()
        when 'expiry_year'  then @validate_expiry_year()
        when 'cvc'          then @validate_cvc()
        when 'match_password'    then @validate_match_password(validator[1])
        when 'routing_number'    then @validate_routing_number()
        when 'account_number'    then @validate_account_number()
        when 'subscription_cost' then @validate_subscription_cost()
        else bud.Logger.error('No validator')

  validate_require: ->
    if _.isEmpty @$container.val()
      @mark_as_invalid @t('empty')

  validate_min_length: (min_length) ->
    if @$container.val().length < min_length
      @mark_as_invalid @t('too_short', { 'minimum': min_length })

  validate_digit: ->
    digit_regex = /^\d+$/
    unless digit_regex.test @$container.val()
      @mark_as_invalid @t('not_an_integer')

  validate_zero: ->
    if @$container.val() <= 0
      @mark_as_invalid @t('zero')

  validate_maximum: (maximum) ->
    if @$container.val() > maximum
      @mark_as_invalid @t('reached_maximum')

  validate_email: ->
    email_regex = /^[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}$/
    unless email_regex.test @$container.val()
      @mark_as_invalid @t()

  validate_slug: ->
    slug_regex = /^[a-zA-Z0-9]+(\w|_|-)+[a-zA-Z0-9]+$/i
    unless slug_regex.test @$container.val()
      @mark_as_invalid @t('not_a_slug')

  validate_match_password: (target_name) ->
    if @$container.val() != @$form.find("input[name='#{target_name}']").val()
      @mark_as_invalid @t('does_not_match_password')

  validate_routing_number: ->
    return if @validate_require()
    return if @validate_digit()

    if @$container.val().length != 9
      @mark_as_invalid @t('not_a_routing_number')

  validate_account_number: ->
    return if @validate_require()
    return if @validate_digit()

    account_number_length = @$container.val().length
    unless account_number_length >= 3 && account_number_length <= 20
      @mark_as_invalid @t('not_an_account_number')

  validate_cc_number: ->
    return if @validate_require()

    cc_number = @$container.val().replace(/\D/g, '')
    if cc_number.length < 14
      @mark_as_invalid @t()

  validate_expiry_month: ->
    return if @validate_require()
    return if @validate_digit()

    if @$container.val() < 1 || @$container.val() > 12
      @mark_as_invalid @t()

  validate_expiry_year: ->
    return if @validate_require()
    return if @validate_digit()

    if @$container.val() < 14
      @mark_as_invalid @t()

  validate_cvc: ->
    return if @validate_require()
    return if @validate_digit()

    cvc = @$container.val()
    if cvc.length < 3
      @mark_as_invalid @t()

  validate_subscription_cost: ->
    return if @validate_require()

    cost = @$container.val()
    unless /^\d+(\.\d+)?$/i.test cost
      return @mark_as_invalid @t('not_a_cost')

    if parseFloat(cost) - parseInt(cost) != 0
      return @mark_as_invalid @t('not_a_whole_number')

    return if @validate_zero()
    return if @validate_maximum(999999)

  get_validators: ->
    result = []
    _.each @$container.attr('validate').toLowerCase().split(','), (validator) =>
      result.push validator.split(':')
    result

  mark_as_invalid: (message) ->
    @$container.removeClass('has-valid').addClass('has-error')
    @$message_container.html(message).show()
    true

  mark_as_valid: ->
    @$container.removeClass('has-error').addClass('has-valid')
    @$message_container.html('').hide()

  t: (key = 'default', params = {}) ->
    result = @error_messages[key] or 'This is not valid.'
    _.each params, (v, k) =>
      result = result.replace("%{#{k}}", v)
    result
