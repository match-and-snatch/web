class bud.widgets.Validator extends bud.Widget
  @SELECTOR: '[validate]'

  initialize: ->
    @$validate_form     = @$container.parents('form')
    @$message_container = @$validate_form.find("[data-field='#{@$container.attr('name')}'], [data-field='#{@$container.data('error_field')}']")
    @$validators        = @prepare_validators()

    @$error_messages    = $('#error_messages').data('error_messages')

    @$container.on 'focusout', @validate

  validate: =>
    @mark_as_valid()

    _.find @$validators, (validator) =>
      switch validator[0]
        when 'require' then @is_empty()
        when 'digit'   then @is_not_digit()
        when 'slug'    then @is_not_slug()
        when 'email'   then @is_not_email()
        when 'match'   then @password_not_matched(validator[1])
        when 'min_length'   then @is_too_short(validator[1])
        when 'cc_number'    then @is_not_cc_number()
        when 'expiry_month' then @is_not_expiry_month()
        when 'expiry_year'  then @is_not_expiry_year()
        when 'cvc'          then @is_not_cvc()
        when 'routing_number'    then @is_not_routing_number()
        when 'account_number'    then @is_not_account_number()
        when 'subscription_cost' then @is_not_subscription_cost()
        else console.log('No validator')

  is_empty: ->
    if _.isEmpty @$container.val()
      @mark_as_invalid @t('empty')

  is_too_short: (min_length) ->
    if @$container.val().length < min_length
      @mark_as_invalid @t('too_short', { 'minimum': min_length })

  is_not_digit: ->
    digit_regex = /^\d+$/
    unless digit_regex.test @$container.val()
      @mark_as_invalid @t('not_an_integer')

  is_zero: ->
    if @$container.val() <= 0
      @mark_as_invalid @t('zero')

  is_greater_than: (maximum) ->
    if @$container.val() > maximum
      @mark_as_invalid @t('reached_maximum')

  is_not_email: ->
    email_regex = /^[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}$/
    unless email_regex.test @$container.val()
      @mark_as_invalid @t()

  is_not_slug: ->
    slug_regex = /^[a-zA-Z0-9]+(\w|_|-)+[a-zA-Z0-9]+$/i
    unless slug_regex.test @$container.val()
      @mark_as_invalid @t('not_a_slug')

  password_not_matched: (target_name) ->
    if @$container.val() != @$validate_form.find("input[name='#{target_name}']").val()
      @mark_as_invalid @t('does_not_match_password')

  is_not_routing_number: ->
    return if @is_empty()
    return if @is_not_digit()

    if @$container.val().length != 9
      @mark_as_invalid @t('not_a_routing_number')

  is_not_account_number: ->
    return if @is_empty()
    return if @is_not_digit()

    account_number_length = @$container.val().length
    unless account_number_length >= 3 && account_number_length <= 20
      @mark_as_invalid @t('not_an_account_number')

  is_not_cc_number: ->
    return if @is_empty()

    cc_number = @$container.val().replace(/\D/g, '')
    if cc_number.length < 14
      @mark_as_invalid @t()

  is_not_expiry_month: ->
    return if @is_empty()
    return if @is_not_digit()

    if @$container.val() < 1 || @$container.val() > 12
      @mark_as_invalid @t()

  is_not_expiry_year: ->
    return if @is_empty()
    return if @is_not_digit()

    if @$container.val() < 14
      @mark_as_invalid @t()

  is_not_cvc: ->
    return if @is_empty()
    return if @is_not_digit()

    cvc = @$container.val()
    if cvc.length < 3
      @mark_as_invalid @t()

  is_not_subscription_cost: ->
    return if @is_empty()

    cost = @$container.val()
    unless /^\d+(\.\d+)?$/i.test cost
      @mark_as_invalid @t('not_a_cost')

    if parseFloat(cost) - parseInt(cost) != 0
      @mark_as_invalid @t('not_a_whole_number')

    return if @is_zero()
    return if @is_greater_than(999999)

  prepare_validators: ->
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
    result = @$error_messages[key]
    _.each params, (v, k) =>
      result = result.replace("%{#{k}}", v)
    result
