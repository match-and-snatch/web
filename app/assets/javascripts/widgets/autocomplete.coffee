class bud.widgets.Autocomplete extends bud.Widget
  @SELECTOR: '.Autocomplete'

  initialize: ->
    form  = @$container.parents('form')
    input = @$container
    input.val('')

    input.on 'keyup', (e) ->
      if e.which == 27
        input.val('')
        form.submit()

    input.on 'input', (e) ->
      form.submit()
