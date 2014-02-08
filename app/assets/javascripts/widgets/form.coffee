class bud.widgets.Form extends bud.Widget
  initialize: ->
    @$container.submit @on_submit
    @$error = @$container.find('.Error')

  on_submit: =>
    bud.Ajax.post @$container.attr('action'), @params(), {
      before: @on_before,
      after:  @on_after,
      failed: @on_fail
    }
    return false

  on_before: =>
    _.each @params(), (value, field) =>
      @$container.find("[data-field=#{field}]").html('')
    @$container.css('opacity', '0.3')

  on_after: =>
    @$container.css('opacity', '1.0')

  on_fail: (response) =>
    if message = response['message']
      if @$error.length > 0 then @$error.html(message)
      else alert(message)

    if errors = response['errors']
      _.each errors, (message, field) =>
        @$container.find("[data-field=#{field}]").html(message)
