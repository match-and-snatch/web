class bud.widgets.Form extends bud.Widget
  @SELECTOR = '.Form'

  initialize: ->
    @$container.submit @on_submit
    @$error = @$container.find('.Error')

  on_submit: =>
    bud.Ajax.post @$container.attr('action'), @params(), {
      replace: @on_replace,
      before:  @on_before,
      after:   @on_after,
      failed:  @on_fail
    }
    return false

  on_replace: (response) =>
    bud.replace_container(@$container, response['html'])

  on_before: =>
    _.each @params(), (value, field) =>
      @$container.find("[data-field=#{field}]").html('')
    @$container.addClass('pending')

  on_after: =>
    @$container.removeClass('pending')

  on_fail: (response) =>
    if message = response['message']
      if @$error.length > 0 then @$error.html(message)
      else alert(message)

    if errors = response['errors']
      _.each errors, (message, field) =>
        @$container.find("[data-field=#{field}]").html(message)

  # Override this method for custom forms
  params: ->
    result = {}
    _.each @$container.find('input, select'), (input) ->
      $input = $(input)
      result[$input.attr('name')] = $input.val()

    result
