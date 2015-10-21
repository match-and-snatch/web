# @data target [String, null]
class bud.widgets.Form extends bud.Widget
  @SELECTOR = '.Form'

  initialize: ->
    @$submit_button = @$container.find('input[type=submit]')
    @submitted_text = @$submit_button.data('submitted_text') || 'Submitted'
    @wait_text      = @$submit_button.data('wait_text') || 'Wait...'
    @submit_text    = @$submit_button.val()

    @requesting = false

    @$container.submit @on_submit
    @$error = @$container.find('.Error')
    if @$container.data('target')
      @$target = bud.get(@$container.data('target'))
    else
      @$target = @$container

  safe_submit: (after) ->
    @submit(after) unless @requesting

  submit: (after) ->
    @after_once = after
    @$container.submit()

  on_submit: =>
    path = @$container.attr('action')
    params = @params()
    callbacks = {
      success: @on_success,
      replace: @on_replace,
      before:  @on_before,
      after:   @on_after,
      prepend: @on_prepend,
      append:  @on_append,
      failed:  @on_fail
    }
    method = @$container.attr('method')

    @requesting = true
    request = new bud.Ajax(path, params, callbacks)
    request.perform_request(method)

    return false

  on_success: =>
    _.each @$container.find('input[data-target]'), (field) ->
      $field = $(field)
      $target = bud.get($field.data('target'))
      bud.replace_html($target, $field.val())

  on_replace: (response) =>
    if @$target == @$container
      bud.replace_container(@$target, response['html'])
    else
      bud.replace_html(@$target, response['html'])

  on_prepend: (response) =>
    bud.prepend_html(@$target, response['html'])

  on_append: (response) =>
    bud.append_html(@$target, response['html'])

  on_before: =>
    @$submit_button.val(@wait_text)
    @$submit_button.attr('disabled', 'disabled')

    _.each @params(), (value, field) =>
      @$container.find("[data-field]").html('').hide()
      @$container.find("[name='#{field}'], [data-error_field='#{field}']").filter('.has-error').addClass('has-valid').removeClass('has-error')
    @$container.addClass('pending')

  on_after: =>
    @requesting = false
    @$container.removeClass('pending')
    @$submit_button.val(@submitted_text)
    setTimeout =>
      @$submit_button.val(@submit_text)
      @$submit_button.removeAttr('disabled')
    , 1000

    if @after_once
      @after_once()
      @after_once = null

  on_fail: (response) =>
    if message = response['message']
      if @$error.length > 0
        @$container.find("input[validate]").addClass('has-error').removeClass('has-valid')
        @$error.html(message)
      else
        alert(message)

    if errors = response['errors']
      _.each errors, (message, field) =>
        @$container.find("[data-field=#{field}]").html(message).show()
        @$container.find("[name='#{field}'], [data-error_field='#{field}']").addClass('has-error').removeClass('has-valid')

      # Scroll to the first error
      first_error   = @$container.find('[data-field]:visible')
      if first_error.length > 0
        top           = first_error.offset().top
        docViewTop    = $(window).scrollTop()
        docViewBottom = docViewTop + $(window).height();

        if (top < (docViewTop + 45) || top > docViewBottom)
          $('html, body').animate({scrollTop: top - 150}, 500)

  # Override this method for custom forms
  params: ->
    result = {}
    _.each @$container.find('input, select, textarea'), (input) ->
      $input = $(input)

      if $input.attr('name')
        if $input.is('[type=checkbox]')
          if $input.is(':checked')
            result[$input.attr('name')] = '1'
          else
            result[$input.attr('name')] = '0'
        else if $input.is('[type=radio]')
          if $input.is(':checked')
            result[$input.attr('name')] = $input.val() || '1'
        else
          result[$input.attr('name')] = $input.val()

    result
