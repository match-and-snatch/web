# Submits form while user inputs text in the form input
# Must be initialized on an input element inside a form
class bud.widgets.Autocomplete extends bud.Widget
  @SELECTOR: '.Autocomplete'

  initialize: ->
    @form  = @$container.parents('form')
    @input = @$container
    @input.val('')

    @input.on 'keyup', (e) =>
      if e.which == 27
        @input.val('')
        @form.submit()
        bud.pub('search.changed', [@input.val()])

    @input.on 'input', =>
      @form.submit()
      bud.pub('search.changed', [@input.val()])
