# @data target [String, null]
class bud.widgets.Form extends bud.Widget
  @SELECTOR = '.Form'

  initialize: ->
    @$submitter = @$container.find('[data-submitter]')

    @submit_buttons = []
    _.each @$container.find('input[type=submit]'), (button) =>
      $btn = $(button)
      $btn.click @on_click
      @submit_buttons.push
        button: $btn
        submitted_text: $btn.data('submitted_text') || 'Submitted'
        wait_text: $btn.data('wait_text') || 'Wait...'
        submit_text: $btn.val()

    @requesting = false

    @$submitter.change @on_submit
    @$container.submit @on_submit
    @$error = @$container.find('.Error')
    if @$container.data('target')
      @$target = bud.get(@$container.data('target'))
    else
      @$target = @$container

  on_click: (e) =>
    @commit_param = e.target.dataset.commit || e.target.value

  safe_submit: (after) ->
    @submit(after) unless @requesting

  submit: (after) ->
    @after_callback = after
    @$container.submit()

  on_submit: =>
    if @$container.data('confirmation')
      bud.confirm 'Are you sure?', @perform_submit
    else
      @perform_submit()

    return false

  perform_submit: =>
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

  on_success: =>
    _.each @$container.find('input[data-target]'), (field) ->
      $field = $(field)
      $target = bud.get($field.data('target'))
      bud.replace_html($target, $field.val())

  on_replace: (response) =>
    if @$target == @$container
      bud.replace_container(@$target, response)
    else
      bud.replace_html(@$target, response)

  on_prepend: (response) =>
    bud.prepend_html(@$target, response)

  on_append: (response) =>
    bud.append_html(@$target, response)

  on_before: =>
    @enable_pending_state()

    _.each @params(), (value, field) =>
      @$container.find("[data-field]").html('').hide()
      @$container.find("[name='#{field}'], [data-error_field='#{field}']").filter('.has-error').addClass('has-valid').removeClass('has-error')

  on_after: =>
    @requesting = false
    @disable_pending_state()
    @after_callback?()

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
    result =
      commit: @commit_param

    _.each @$container.find('input, select, textarea'), (input) ->
      $input = $(input)

      if $input.attr('name')
        if $input.is('[type=checkbox]')
          field_name = $input.attr('name')
          if /^.+\[\]$/.test(field_name)
            result[field_name] = [] unless result[field_name]
            result[field_name].push($input.val()) if $input.is(':checked')
          else
            result[field_name] = if $input.is(':checked') then '1' else '0'
        else if $input.is('[type=radio]')
          if $input.is(':checked')
            result[$input.attr('name')] = $input.val() || '1'
        else
          result[$input.attr('name')] = $input.val()

    result

  enable_pending_state: ->
    @$container.addClass('pending')
    _.each @submit_buttons, (params) =>
      params.button.val(params.wait_text).attr('disabled', 'disabled')


  disable_pending_state: ->
    @$container.removeClass('pending')
    _.each @submit_buttons, (params) =>
      params.button.val(params.submitted_text)
    setTimeout =>
      _.each @submit_buttons, (params) =>
        params.button.val(params.submit_text).removeAttr('disabled')
    , 1000
