class bud.widgets.Form extends bud.Widget
  @SELECTOR = '.Form'

  initialize: ->
    @$container.submit @on_submit
    @$error = @$container.find('.Error')

  on_submit: =>
    bud.Ajax.post @$container.attr('action'), @params(), {
      success: @on_success,
      replace: @on_replace,
      before:  @on_before,
      after:   @on_after,
      failed:  @on_fail
    }
    return false

  on_success: =>
    _.each @$container.find('input[data-target]'), (field) ->
      $field = $(field)
      $target = $("[data-identifier=#{$field.data('target')}]")
      $target.html($field.val())

  on_replace: (response) =>
    bud.replace_container(@$container, response['html'])

  on_before: =>
    _.each @params(), (value, field) =>
      @$container.find("[data-field]").html('').hide()
    @$container.addClass('pending')

  on_after: =>
    @$container.removeClass('pending')

  on_fail: (response) =>
    if message = response['message']
      if @$error.length > 0 then @$error.html(message)
      else alert(message)

    if errors = response['errors']
      _.each errors, (message, field) =>
        @$container.find("[data-field=#{field}]").html(message).show()

  # Override this method for custom forms
  params: ->
    result = {}
    _.each @$container.find('input, select, textarea'), (input) ->
      $input = $(input)
      result[$input.attr('name')] = $input.val()

    result
